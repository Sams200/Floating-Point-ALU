library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity wallaceTree32bit is
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           res : out STD_LOGIC_VECTOR (63 downto 0));
end wallaceTree32bit;

architecture Behavioral of wallaceTree32bit is

component wallaceTree16bit is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           res : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal aHi,aLo:std_logic_vector(15 downto 0);
signal bHi,bLo:std_logic_vector(15 downto 0);

signal p0,p1,p2,p3:std_logic_vector(31 downto 0);

begin

aHi<=a(31 downto 16);
aLo<=a(15 downto 0);

bHi<=b(31 downto 16);
bLo<=b(15 downto 0);

mul0: wallaceTree16bit port map(a=>aLo,b=>bLo,res=>p0);
mul1: wallaceTree16bit port map(a=>aLo,b=>bHi,res=>p1);
mul2: wallaceTree16bit port map(a=>aHi,b=>bLo,res=>p2);
mul3: wallaceTree16bit port map(a=>aHi,b=>bHi,res=>p3);

res<=(x"00000000" & p0) + (x"0000" & p1 & x"0000") + (x"0000" & p2 & x"0000") + (p3 & x"00000000");
end Behavioral;

