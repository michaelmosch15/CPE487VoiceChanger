library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_mod is
    port (
        clk_50MHz : in  std_logic;
        btnU      : in  std_logic;
        SW        : in  std_logic_vector(7 downto 0);

        dac_MCLK  : out std_logic;
        dac_LRCK  : out std_logic;
        dac_SCLK  : out std_logic;
    dac_SDIN  : out std_logic;

    adc_SDOUT : in  std_logic;

    LED       : out std_logic_vector(1 downto 0)
    );
end top_mod;

architecture Behavioral of top_mod is
    component adc is
        port (
            SCLK   : in  std_logic;
            LRCK   : in  std_logic;
            SDOUT  : in  std_logic;
            L_data : out signed(15 downto 0);
            R_data : out signed(15 downto 0)
        );
    end component;

    component dac_if is
        port (
            SCLK    : in  std_logic;
            L_start : in  std_logic;
            R_start : in  std_logic;
            L_data  : in  signed(15 downto 0);
            R_data  : in  signed(15 downto 0);
            SDATA   : out std_logic
        );
    end component;

    signal tcount                 : unsigned(19 downto 0) := (others => '0');
    signal audio_CLK              : std_logic;
    signal sclk                   : std_logic;
    signal dac_load_L, dac_load_R : std_logic;
    signal L_in, R_in             : signed(15 downto 0) := (others => '0');
    signal lrck_prev              : std_logic := '0';
    signal frame_cnt              : unsigned(23 downto 0) := (others => '0');
    signal activity_timer         : unsigned(23 downto 0) := (others => '0');
    signal sdout_prev             : std_logic := '0';

begin

process(clk_50MHz)
begin
    if rising_edge(clk_50MHz) then
        -- free-running timing counter used to derive SCLK and LRCK
        tcount <= tcount + 1;
    end if;
end process;

dac_MCLK  <= not tcount(1);  -- ~12.5 MHz (MCLK)
sclk      <= tcount(4);      -- ~3.125 MHz (BCLK/SCLK)
audio_CLK <= tcount(10);     -- ~48.8 kHz (LRCK) => MCLK/LRCK ≈ 256

dac_LRCK <= audio_CLK;
dac_SCLK <= sclk;

-- generate 1-clock SCLK-synchronous load pulses for DAC when LRCK (audio_CLK)
-- transitions indicate a new word is available from the ADC. We detect LRCK
-- edges on the falling edge of SCLK so pulses align with dac_if's falling-edge load.

process(sclk)
begin
    if falling_edge(sclk) then
        -- default no-load
        dac_load_L <= '0';
        dac_load_R <= '0';

        -- detect LRCK rising edge -> left word completed
        if (lrck_prev = '0') and (audio_CLK = '1') then
            dac_load_L <= '1';
            frame_cnt <= frame_cnt + 1;
        -- detect LRCK falling edge -> right word completed
        elsif (lrck_prev = '1') and (audio_CLK = '0') then
            dac_load_R <= '1';
        end if;

        -- update previous LRCK state for next falling-edge sample
        lrck_prev <= audio_CLK;

        -- simple activity monitor: keep LED(1) lit when ADC serial data toggles
        if adc_SDOUT /= sdout_prev then
            activity_timer <= (others => '1');
        elsif activity_timer /= 0 then
            activity_timer <= activity_timer - 1;
        end if;

        sdout_prev <= adc_SDOUT;
    end if;
end process;

LED(0) <= frame_cnt(frame_cnt'high);                                   -- slow blink when LRCK edges occur
LED(1) <= '1' when activity_timer /= 0 else '0';                        -- lights when SDOUT is toggling (audio activity)

u_adc : adc
    port map (
        SCLK   => sclk,
        LRCK   => audio_CLK,
        SDOUT  => adc_SDOUT,
        L_data => L_in,
        R_data => R_in
    );

u_dac : dac_if
    port map (
        SCLK    => sclk,
        L_start => dac_load_L,
        R_start => dac_load_R,
        L_data  => L_in,
        R_data  => R_in,
        SDATA   => dac_SDIN
    );

end Behavioral;
