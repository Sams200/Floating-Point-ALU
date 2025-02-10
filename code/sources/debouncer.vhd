library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           dbOut : out STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is

signal Q1,Q2,Q3:std_logic;
begin


process(clk)

begin
    if (clk'event and clk='1') then
        Q1<=btn;
        Q2<=Q1;
        Q3<=Q2;
    end if;

end process;

dbOut<= Q1 and Q2 and (not Q3);
end Behavioral;
