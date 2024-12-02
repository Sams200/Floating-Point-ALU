----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2024 11:43:10 PM
-- Design Name: 
-- Module Name: tbWallace32bit - Behavioral
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
use IEEE.math_real.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tbWallace32bit is
--  Port ( );
end tbWallace32bit;

architecture Behavioral of tbWallace32bit is

component wallaceTree32bit is
	Port (
		a:in std_logic_vector(31 downto 0);
		b:in std_logic_vector(31 downto 0);
		res:out std_logic_vector(63 downto 0)
	);
end component;

signal a,b:std_logic_vector(31 downto 0):=x"00000000";
signal mul:std_logic_vector(63 downto 0);
constant t:time:=10ns;


begin

a1:wallaceTree32bit port map(a=>a, b=>b, res=>mul);

process
variable seed1:positive:=5345;
variable seed2:positive:=6748293;
variable x:real;
variable y:real;

begin

	for I in 0 to 31 loop
	
		uniform(seed1,seed2,x);
		uniform(seed1,seed2,y);
		a<=std_logic_vector(to_unsigned(integer(floor(x * 4294967295.0)),32));
		b<=std_logic_vector(to_unsigned(integer(floor(y * 4294967295.0)),32));
		wait for t;
	end loop;
	
	wait for 10*t;

end process;

end Behavioral;

