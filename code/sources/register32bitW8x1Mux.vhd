library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register32bitW8x1Mux is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           C : in STD_LOGIC_VECTOR (31 downto 0);
           D : in STD_LOGIC_VECTOR (31 downto 0);
           E : in STD_LOGIC_VECTOR (31 downto 0);
           F : in STD_LOGIC_VECTOR (31 downto 0);
           G : in STD_LOGIC_VECTOR (31 downto 0);
           H : in STD_LOGIC_VECTOR (31 downto 0);
           S: in std_logic_vector(2 downto 0);
           write : in STD_LOGIC;
           clk : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (31 downto 0));
end register32bitW8x1Mux;

architecture Behavioral of register32bitW8x1Mux is

signal mem:std_logic_vector(31 downto 0);
begin

output<=mem;

process(clk)
begin
	if(clk'event and clk='1') then
		if(write='1') then
			case S is
				when "000"=>
					mem<=A;
				when "001"=>
					mem<=B;
				when "010"=>
					mem<=C;
				when "011"=>
					mem<=D;
				when "100"=>
					mem<=E;
				when "101"=>
					mem<=F;
				when "110"=>
					mem<=G;
				when "111"=>
					mem<=H;
				when others=>
					mem<=A;
			end case;
		else
			mem<=mem;
		end if;
	end if;
end process;

end Behavioral;
