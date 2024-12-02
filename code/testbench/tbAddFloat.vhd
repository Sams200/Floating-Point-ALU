library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tbAddFloat is
--  Port ( );
end tbAddFloat;

architecture Behavioral of tbAddFloat is

component adderFloat is
    Port ( clk : in STD_LOGIC;
           reset:in STD_LOGIC;
           start:in std_logic;
           num1:in std_logic_vector(31 downto 0);
           num2:in std_logic_vector(31 downto 0);
           res:out std_logic_vector(31 downto 0);
           dbState:out std_logic_vector(3 downto 0);
           working : out STD_LOGIC);
end component;

signal clk,reset,start,working:std_logic:='0';
signal num1,num2,res:std_logic_vector(31 downto 0);
signal dbState:std_logic_vector(3 downto 0);

function to_string ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
return b;
end function;


begin

clk<=not clk after 5ns;

tb:adderFloat port map(
	clk=>clk,
	reset=>reset,
	start=>start,
	num1=>num1,
	num2=>num2,
	res=>res,
	working=>working,
	dbState=>dbState
);

process
begin

	num1<=b"0_10000000_01100111111001101111111"; -- 2.8117368221282958984375
	num2<=b"0_10000100_00000011111001011101111"; -- 32.487239837646484375
	start<='1';
	
	--expecting 35.29897665977478027344
	-- 420d3227
	wait on clk;
	start<='0';
	wait until working='0';
	
	report to_string(res);
	wait on clk;
	
	num1<=b"01000010000000001000000101000001"; --32.126225
	num2<=b"01000010010011101110001001110101"; --51.721149
	start<='1';
	
	-- expecting 83.847374
	-- 42a7b1db
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	wait for 1000ns;
end process;

end Behavioral;
