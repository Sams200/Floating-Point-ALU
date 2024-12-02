library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register64bitW4x1Mux is
    Port ( A : in STD_LOGIC_VECTOR (63 downto 0);
           B : in STD_LOGIC_VECTOR (63 downto 0);
           C : in STD_LOGIC_VECTOR (63 downto 0);
           D : in STD_LOGIC_VECTOR (63 downto 0);
           S: in std_logic_vector(1 downto 0);
           write : in STD_LOGIC;
           clk : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (63 downto 0));
end register64bitW4x1Mux;

architecture Behavioral of register64bitW4x1Mux is

signal mem:std_logic_vector(63 downto 0);
begin

output<=mem;

process(clk)
begin
	if(clk'event and clk='1') then
		if(write='1') then
			case S is
				when "00"=>
					mem<=A;
				when "01"=>
					mem<=B;
				when "10"=>
					mem<=C;
				when "11"=>
					mem<=D;
				when others=>
					mem<=A;
			end case;
		else
			mem<=mem;
		end if;
	end if;
end process;

end Behavioral;
