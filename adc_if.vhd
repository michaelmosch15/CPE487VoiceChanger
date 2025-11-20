library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc is
    port (
        SCLK   : in  std_logic;
        LRCK   : in  std_logic;
        SDOUT  : in  std_logic;
        L_data : out signed(15 downto 0);
        R_data : out signed(15 downto 0)
    );
end adc;

architecture rtl of adc is
    signal sr      : std_logic_vector(15 downto 0) := (others => '0');
    signal lrck_d  : std_logic := '0';
    signal L_reg   : std_logic_vector(15 downto 0) := (others => '0');
    signal R_reg   : std_logic_vector(15 downto 0) := (others => '0');
begin

process(SCLK)
begin
    if falling_edge(SCLK) then
        sr <= sr(14 downto 0) & SDOUT;
        lrck_d <= LRCK;

        if (lrck_d = '0' and LRCK = '1') then
            L_reg <= sr;
        elsif (lrck_d = '1' and LRCK = '0') then
            R_reg <= sr;
        end if;
    end if;
end process;

L_data <= signed(L_reg);
R_data <= signed(R_reg);

end rtl;
