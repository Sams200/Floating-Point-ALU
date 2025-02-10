library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator32bit is
    Port ( numA : in STD_LOGIC_vector(31 downto 0);
           numB : in STD_LOGIC_vector(31 downto 0);
           eq : out STD_LOGIC;
           greater : out STD_LOGIC);
end comparator32bit;

architecture Behavioral of comparator32bit is

begin


process(numA,numB)
begin

if(numA>numB) then
	greater<='1';
else
	greater<='0';
end if;

if(numA=numB) then
	eq<='1';
else
	eq<='0';
end if;

end process;
end Behavioral;
