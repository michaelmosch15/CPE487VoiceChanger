library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dac_if is
    port (
        SCLK    : in  std_logic;
        L_start : in  std_logic;
        R_start : in  std_logic;
        L_data  : in  signed(15 downto 0);
        R_data  : in  signed(15 downto 0);
        SDATA   : out std_logic
    );
end dac_if;

architecture Behavioral of dac_if is
    signal sreg : std_logic_vector(15 downto 0) := (others => '0');
begin

dac_proc : process
begin
    wait until falling_edge(SCLK);

    if L_start = '1' then
        sreg <= std_logic_vector(L_data);
    elsif R_start = '1' then
        sreg <= std_logic_vector(R_data);
    else
        sreg <= sreg(14 downto 0) & '0';  -- shift MSB-first
    end if;
end process;

SDATA <= sreg(15);

end Behavioral;
