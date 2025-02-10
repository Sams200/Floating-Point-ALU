library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tbMulFloat is
--  Port ( );
end tbMulFloat;

architecture Behavioral of tbMulFloat is

component aluFloat is
Port (
	clk : in STD_LOGIC;
	start:in std_logic;
	reset:in std_logic;
	op : in STD_LOGIC;
	
	num1 : in STD_LOGIC_VECTOR (31 downto 0);
	num2 : in STD_LOGIC_VECTOR (31 downto 0);
	
	res : out STD_LOGIC_VECTOR (31 downto 0);
	working:out std_logic;
	infinityFlag:out std_logic;
	zeroFlag:out std_logic;
	nanFlag:out std_logic
);
end component;

signal clk,reset,start,working,op:std_logic:='0';
signal num1,num2,res:std_logic_vector(31 downto 0);

signal infinityFlag,zeroFlag,nanFlag:std_logic:='0';

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

tb:aluFloat port map(
	clk=>clk,
	reset=>reset,
	start=>start,
	op=>op,
	
	num1=>num1,
	num2=>num2,
	res=>res,
	working=>working,
	
	infinityFlag=>infinityFlag,
	zeroFlag=>zeroFlag,
	nanFlag=>nanFlag
);

process
begin
	op<='1';
	start<='1';
	num1<="01000010000011010011001000100111"; --35.298976898193359375
	num2<="01000000000101001001001010001110"; --2.321444988250732421875
	
	--expecting 81.94463245721374278219
	--42a3e3a6
	wait on clk;
	start<='0';
	wait until working='0';
	
	report to_string(res);
	wait on clk;
	--=========================================================
	
	op<='1';
	start<='1';
	num1<="11000010000011010011001000100111"; -- -35.298976898193359375
	num2<="01000000000101001001001010001110"; -- 2.321444988250732421875

	--expecting -81.94463245721374278219
	--c2a3e3a6
	wait on clk;
	start<='0';
	wait until working='0';
	
	report to_string(res);
	wait on clk;
	--=========================================================
	num1<=b"01000010000000001000000101000001"; --32.126225
	num2<=b"00000000000000000000000000000000"; --0
	start<='1';
	
	-- expecting 0
	-- 00000000
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	
	num1<=b"01000010000000001000000101000001"; --32.126225
	num2<=b"0_11111111_00000000000000000000001"; --Nan
	start<='1';
	
	-- expecting NaN
	-- 7fffffff
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	
	num1<=b"01000010000000001000000101000001"; --32.126225
	num2<=b"0_11111111_00000000000000000000000"; --+inf
	start<='1';
	
	-- expecting +inf
	-- 7f800000
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	
	num1<=b"00000000000000000000000000000000"; --0
	num2<=b"0_11111111_00000000000000000000000"; --+inf
	start<='1';
	
	-- expecting NaN
	-- 7fffffff
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	
	num1<=b"01111110001000000111000010100100"; --5.3315336e37
	num2<=b"01111100101110100111000010100100"; --7.744415e36
	start<='1';
	
	-- expecting overflow
	-- infinity flag
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	
	num1<=b"00000001101110100111000010100100"; --6.848724e-38
	num2<=b"00000100111100100001110010010100"; --5.692017e-36
	start<='1';
	
	-- expecting underflow
	-- zero flag
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================

	wait;

end process;
end Behavioral;