library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity siren is
    port (
        clk_50MHz : in  std_logic;           -- 50 MHz system clock
        adc_SDOUT : in  std_logic;           -- serial data from Pmod I2S2 ADC (blue jack)

        dac_MCLK  : out std_logic;           -- master clock to Pmod I2S2 DAC (green jack)
        dac_LRCK  : out std_logic;           -- left/right clock
        dac_SCLK  : out std_logic;           -- serial bit clock
        dac_SDIN  : out std_logic;           -- serial data to DAC

        LED       : out std_logic_vector(1 downto 0)
    );
end siren;

architecture Behavioral of siren is

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

    component adc is
        port (
            SCLK   : in  std_logic;
            LRCK   : in  std_logic;
            SDOUT  : in  std_logic;
            L_data : out signed(15 downto 0);
            R_data : out signed(15 downto 0)
        );
    end component;

    signal tcount                 : unsigned(19 downto 0) := (others => '0');
    signal dac_load_L, dac_load_R : std_logic := '0';
    signal sclk                   : std_logic := '0';
    signal audio_CLK              : std_logic := '0';

    signal L_in, R_in             : signed(15 downto 0) := (others => '0');
    signal data_L, data_R         : signed(15 downto 0) := (others => '0');

    signal led_activity_timer     : unsigned(23 downto 0) := (others => '0');
    signal sdout_prev             : std_logic := '0';

begin

    -- replicate original Lab 5 timing counter so the board pins and DAC clocks match the reference design
    tim_pr : process(clk_50MHz)
    begin
        if rising_edge(clk_50MHz) then
            if (tcount(9 downto 0) >= X"00F") and (tcount(9 downto 0) < X"02E") then
                dac_load_L <= '1';
            else
                dac_load_L <= '0';
            end if;

            if (tcount(9 downto 0) >= X"20F") and (tcount(9 downto 0) < X"22E") then
                dac_load_R <= '1';
            else
                dac_load_R <= '0';
            end if;

            tcount <= tcount + 1;
        end if;
    end process;

    dac_MCLK  <= not tcount(1);  -- 12.5 MHz
    sclk      <= tcount(4);      -- ~1.56 MHz serial clock
    audio_CLK <= tcount(9);      -- ~48.8 kHz LRCK

    dac_LRCK <= audio_CLK;
    dac_SCLK <= sclk;

    -- Instantiate ADC interface to capture samples from the Pmod I2S2 input
    adc_in : adc
        port map (
            SCLK   => sclk,
            LRCK   => audio_CLK,
            SDOUT  => adc_SDOUT,
            L_data => L_in,
            R_data => R_in
        );

    data_L <= L_in;
    data_R <= R_in;

    -- Existing DAC serializer (unchanged pin names/timing)
    dac_out : dac_if
        port map (
            SCLK    => sclk,
            L_start => dac_load_L,
            R_start => dac_load_R,
            L_data  => data_L,
            R_data  => data_R,
            SDATA   => dac_SDIN
        );

    -- Simple LED debug: LED(0) = LRCK heartbeat, LED(1) = ADC activity
    LED(0) <= audio_CLK;

    process(sclk)
    begin
        if falling_edge(sclk) then
            if adc_SDOUT /= sdout_prev then
                led_activity_timer <= (others => '1');
            elsif led_activity_timer /= 0 then
                led_activity_timer <= led_activity_timer - 1;
            end if;
            sdout_prev <= adc_SDOUT;
        end if;
    end process;

    LED(1) <= '1' when led_activity_timer /= 0 else '0';

end Behavioral;
