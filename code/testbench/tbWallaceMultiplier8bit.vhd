library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tbWallaceMultiplier8bit is
--  Port ( );
end tbWallaceMultiplier8bit;

architecture Behavioral of tbWallaceMultiplier8bit is

component wallaceTree8bit is
	Port (
		a:in std_logic_vector(7 downto 0);
		b:in std_logic_vector(7 downto 0);
		res:out std_logic_vector(15 downto 0)
	);
end component;

signal a,b:std_logic_vector(7 downto 0):=x"00";
signal mul:std_logic_vector(15 downto 0);
constant t:time:=10ns;


begin

a1:wallaceTree8bit port map(a=>a, b=>b, res=>mul);

process
variable seed1:positive:=5345;
variable seed2:positive:=6748293;
variable x:real;
variable y:real;

begin

	for I in 0 to 31 loop
	
		uniform(seed1,seed2,x);
		uniform(seed1,seed2,y);
		a<=std_logic_vector(to_unsigned(integer(floor(x * 256.0)),8));
		b<=std_logic_vector(to_unsigned(integer(floor(y * 256.0)),8));
		wait for t;
	end loop;
	
	wait for 10*t;

end process;

end Behavioral;
