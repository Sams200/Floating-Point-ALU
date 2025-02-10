library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity wallaceTree16bit is
	Port (
		a:in std_logic_vector(15 downto 0);
		b:in std_logic_vector(15 downto 0);
		res:out std_logic_vector(31 downto 0)
	);
end wallaceTree16bit;

architecture Behavioral of wallaceTree16bit is

component wallaceTree8bit is
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           res : out STD_LOGIC_VECTOR (15 downto 0));
end component;

signal aHi,aLo:std_logic_vector(7 downto 0);
signal bHi,bLo:std_logic_vector(7 downto 0);

signal p0,p1,p2,p3:std_logic_vector(15 downto 0);

begin

aHi<=a(15 downto 8);
aLo<=a(7 downto 0);

bHi<=b(15 downto 8);
bLo<=b(7 downto 0);

mul0: wallaceTree8bit port map(a=>aLo,b=>bLo,res=>p0);
mul1: wallaceTree8bit port map(a=>aLo,b=>bHi,res=>p1);
mul2: wallaceTree8bit port map(a=>aHi,b=>bLo,res=>p2);
mul3: wallaceTree8bit port map(a=>aHi,b=>bHi,res=>p3);

res<=(x"0000" & p0) + (x"00" & p1 & x"00") + (x"00" & p2 & x"00") + (p3 & x"0000");
end Behavioral;
