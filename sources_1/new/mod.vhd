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

        adc_SDOUT : in  std_logic
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

    constant L_START_LO : unsigned(9 downto 0) := to_unsigned(15, 10);
    constant L_START_HI : unsigned(9 downto 0) := to_unsigned(46, 10);
    constant R_START_LO : unsigned(9 downto 0) := to_unsigned(527, 10);
    constant R_START_HI : unsigned(9 downto 0) := to_unsigned(558, 10);

begin

process(clk_50MHz)
begin
    if rising_edge(clk_50MHz) then

        if (tcount(9 downto 0) >= L_START_LO) and (tcount(9 downto 0) < L_START_HI) then
            dac_load_L <= '1';
        else
            dac_load_L <= '0';
        end if;

        if (tcount(9 downto 0) >= R_START_LO) and (tcount(9 downto 0) < R_START_HI) then
            dac_load_R <= '1';
        else
            dac_load_R <= '0';
        end if;

        tcount <= tcount + 1;
    end if;
end process;

dac_MCLK  <= not tcount(1);
sclk      <= tcount(4);
audio_CLK <= tcount(9);

dac_LRCK <= audio_CLK;
dac_SCLK <= sclk;

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
