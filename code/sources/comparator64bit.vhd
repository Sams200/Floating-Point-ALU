library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator64bit is
    Port ( numA : in STD_LOGIC_vector(63 downto 0);
           numB : in STD_LOGIC_vector(63 downto 0);
           eq : out STD_LOGIC;
           greater : out STD_LOGIC);
end comparator64bit;

architecture Behavioral of comparator64bit is

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
