library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity wallaceTree8bit is
	Port (
		a:in std_logic_vector(7 downto 0);
		b:in std_logic_vector(7 downto 0);
		res:out std_logic_vector(15 downto 0)
	);
end wallaceTree8bit;

architecture Behavioral of wallaceTree8bit is

component wallaceTree4bit is
    Port ( a : in STD_LOGIC_VECTOR (3 downto 0);
           b : in STD_LOGIC_VECTOR (3 downto 0);
           mul : out STD_LOGIC_VECTOR (7 downto 0));
end component;

signal aHi,aLo:std_logic_vector(3 downto 0);
signal bHi,bLo:std_logic_vector(3 downto 0);

signal p0,p1,p2,p3:std_logic_vector(7 downto 0);

begin

aHi<=a(7 downto 4);
aLo<=a(3 downto 0);

bHi<=b(7 downto 4);
bLo<=b(3 downto 0);

mul0: wallaceTree4bit port map(a=>aLo,b=>bLo,mul=>p0);
mul1: wallaceTree4bit port map(a=>aLo,b=>bHi,mul=>p1);
mul2: wallaceTree4bit port map(a=>aHi,b=>bLo,mul=>p2);
mul3: wallaceTree4bit port map(a=>aHi,b=>bHi,mul=>p3);

res<=(x"00" & p0) + (x"0" & p1 & x"0") + (x"0" & p2 & x"0") + (p3 & x"00");
end Behavioral;
