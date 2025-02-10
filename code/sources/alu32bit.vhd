library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity alu32bit is
Port ( 		
		numA : in STD_LOGIC_VECTOR (31 downto 0);
	   	numB : in STD_LOGIC_VECTOR (31 downto 0);
	   	op : in STD_LOGIC_vector(1 downto 0);
	   	output : out STD_LOGIC_VECTOR (31 downto 0);
	   	cout: out std_logic);
end alu32bit;

architecture Behavioral of alu32bit is

signal extA,extB,result:std_logic_vector(32 downto 0);
begin

extA<="0" & numA;
extB<="0" & numB;

cout<=result(32);
output<=result(31 downto 0);

process(op,extA,extB)
begin
	case op is
		when "00"=>
			result<=extA+extB;
		when "01"=>
			result<=extA - extB;
		when "10"=>
			result<=extA+1;
		when "11"=>
			result<=extA-1;
		when others=>
			result<=extA+extB;
	end case;
end process;

end Behavioral;
