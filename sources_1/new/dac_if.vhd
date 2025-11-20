library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dac_if is
    port (
        SCLK    : in  std_logic;                       -- I2S serial clock
        L_start : in  std_logic;                       -- load left word
        R_start : in  std_logic;                       -- load right word
        L_data  : in  signed(15 downto 0);             -- 16-bit sample input (will be sign-extended)
        R_data  : in  signed(15 downto 0);             -- 16-bit sample input (will be sign-extended)
        SDATA   : out std_logic
    );
end dac_if;

architecture Behavioral of dac_if is
    -- Use a 24-bit shift register for CS4344 24-bit frames. Input 16-bit samples are
    -- sign-extended to 24 bits so MSB alignment is preserved and the DAC receives
    -- the expected 24-bit word length.
    signal sreg24 : std_logic_vector(23 downto 0) := (others => '0');
begin

    process(SCLK)
    begin
        if falling_edge(SCLK) then
            if L_start = '1' then
                -- sign-extend 16-bit signed value to 24 bits, MSB-aligned
                sreg24 <= std_logic_vector(resize(L_data, 24));
            elsif R_start = '1' then
                sreg24 <= std_logic_vector(resize(R_data, 24));
            else
                -- shift left (MSB-first): output is the MSB
                sreg24 <= sreg24(22 downto 0) & '0';
            end if;
        end if;
    end process;

    SDATA <= sreg24(23);

end Behavioral;
