----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2024 08:33:31 PM
-- Design Name: 
-- Module Name: tbMulFloat - Behavioral
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

entity tbMulFloat is
--  Port ( );
end tbMulFloat;

architecture Behavioral of tbMulFloat is

component multiplierFloat is
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

begin

clk<=not clk after 5ns;

tb:multiplierFloat port map(
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

	start<='1';
	num1<="01000010000011010011001000100111"; --35.298976898193359375
	num2<="01000000000101001001001010001110"; --2.321444988250732421875
	wait on clk;
	start<='0';
	
	--expecting 81.94463245721374278219
	--42a3e3a7
	wait for 1000ns;

end process;
end Behavioral;
