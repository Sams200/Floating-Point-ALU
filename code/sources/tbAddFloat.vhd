----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/09/2024 06:39:44 PM
-- Design Name: 
-- Module Name: tbAddFloat - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tbAddFloat is
--  Port ( );
end tbAddFloat;

architecture Behavioral of tbAddFloat is

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

	num1<=b"0_10000000_01100111111001101111111"; -- 2.8117368221282958984375
	num2<=b"0_10000100_00000011111001011101111"; -- 32.487239837646484375
	start<='1';
	
	--expecting 35.29897665977478027344
	-- 420d3226
	wait on clk;
	start<='0';
	wait until working='0';
	
	report to_string(res);
	wait on clk;
	--=========================================================
	num1<=b"01000010000000001000000101000001"; -- 32.126225
	num2<=b"01000010010011101110001001110101"; -- 51.721149
	start<='1';
	
	-- expecting 83.847374
	-- 42a7b1db
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	num1<=b"01000010000000001000000101000001"; -- 32.126225
	num2<=b"11000010010011101110001001110101"; -- -51.721149
	start<='1';
	
	-- expecting -19.594924
	-- c19cc268
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	num1<=b"01000010000000001000000101000001"; --32.126225
	num2<=b"00000000000000000000000000000000"; --0
	start<='1';
	
	-- expecting 32.126225
	-- 42008141
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	
	
	--=========================================================
	num1<=b"0_11111111_00000000000000000000001"; --NaN
	num2<=b"01000010010011101110001001110101"; --51.721149
	start<='1';
	
	-- expecting NaN
	-- 7fffffff
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	--=========================================================
	num1<=b"01000010010011101110001001110101"; --51.721149
	num2<=b"0_11111111_00000000000000000000001"; --NaN
	start<='1';
	
	-- expecting NaN
	-- 7fffffff
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	--=========================================================
	num1<=b"01000010010011101110001001110101"; --51.721149
	num2<=b"0_11111111_00000000000000000000000"; -- +inf
	start<='1';
	
	-- expecting +inf
	-- 7f800000
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	--=========================================================
	num1<=b"1_11111111_00000000000000000000000"; -- -inf
	num2<=b"0_11111111_00000000000000000000000"; -- +inf
	start<='1';
	
	-- expecting +NaN
	-- 7fffffff
	wait on clk;
	start<='0';
	wait until working='0';
	report to_string(res);
	wait on clk;
	
	wait for 1000ns;
end process;

end Behavioral;