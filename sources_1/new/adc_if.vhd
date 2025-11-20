library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc is
    port (
        SCLK   : in  std_logic;                     -- I2S serial clock
        LRCK   : in  std_logic;                     -- left/right word select (also called WS)
        SDOUT  : in  std_logic;                     -- serial data out from ADC
        L_data : out signed(15 downto 0);           -- 16-bit left channel output (MSB-aligned)
        R_data : out signed(15 downto 0)            -- 16-bit right channel output (MSB-aligned)
    );
end adc;

architecture rtl of adc is
    -- capture 24-bit I2S words (CS5343 outputs 24-bit samples). We sample on falling edge
    -- of SCLK and latch the full 24-bit word on LRCK transitions. Then we present the
    -- top 16 bits (MSBs) as the 16-bit outputs to match the existing DAC path.
    signal sr24    : std_logic_vector(23 downto 0) := (others => '0');
    signal lrck_d  : std_logic := '0';
    signal L_reg24 : std_logic_vector(23 downto 0) := (others => '0');
    signal R_reg24 : std_logic_vector(23 downto 0) := (others => '0');
    signal L_reg16 : std_logic_vector(15 downto 0) := (others => '0');
    signal R_reg16 : std_logic_vector(15 downto 0) := (others => '0');
begin

    process(SCLK)
    begin
        if falling_edge(SCLK) then
            -- shift MSB-first: push newest bit into LSB side and shift left
            sr24 <= sr24(22 downto 0) & SDOUT;
            lrck_d <= LRCK;

            -- latch previous shift register value on LRCK edge to capture completed word
            if (lrck_d = '0' and LRCK = '1') then
                -- LRCK rising: previous word was Left channel (word just completed)
                L_reg24 <= sr24;
                -- take top 16 bits (MSBs) of 24-bit word for 16-bit path
                L_reg16 <= sr24(23 downto 8);
            elsif (lrck_d = '1' and LRCK = '0') then
                -- LRCK falling: previous word was Right channel
                R_reg24 <= sr24;
                R_reg16 <= sr24(23 downto 8);
            end if;
        end if;
    end process;

    -- present 16-bit signed outputs (MSB-aligned from 24-bit ADC)
    L_data <= signed(L_reg16);
    R_data <= signed(R_reg16);

end rtl;
