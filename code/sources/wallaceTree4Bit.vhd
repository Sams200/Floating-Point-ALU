----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/22/2024 06:08:45 PM
-- Design Name: 
-- Module Name: wallaceTree4bit - Behavioral
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

entity wallaceTree4bit is
    Port ( a : in STD_LOGIC_VECTOR (3 downto 0);
           b : in STD_LOGIC_VECTOR (3 downto 0);
           mul : out STD_LOGIC_VECTOR (7 downto 0));
end wallaceTree4bit;

architecture Behavioral of wallaceTree4bit is

component fullAdder is
    Port ( x : in STD_LOGIC;
           y : in STD_LOGIC;
           cin : in STD_LOGIC;
           s : out STD_LOGIC;
           cout : out STD_LOGIC);
end component;

signal s00,s01,s10,s11,s12,s13,s20,s21,s22,s23,s24,s25:std_logic;
signal c00,c01,c10,c11,c12,c13,c20,c21,c22,c23,c24,c25:std_logic;

signal a00,a01,a10,a11,a12,a13,a20,a21,a22,a23,a24,a25:std_logic;
signal b00,b01,b10,b11,b12,b13,b20,b21,b22,b23,b24,b25:std_logic;

signal cin12:std_logic;
begin

a00<=(a(2) and b(2));
b00<=(a(3) and b(1));
l00:fullAdder port map(x=>a00,y=>b00, cin=>'0', s=>s00,cout=>c00);

a01<=a(2) and b(1);
b01<=a(3) and b(0);
l01:fullAdder port map(x=>a01,y=>b01,cin=>'0',s=>s01,cout=>c01);

a10<=a(3) and b(2);
b10<=a(2) and b(3);
l10:fullAdder port map(x=>a10,y=>b10,cin=>c00,s=>s10,cout=>c10);

a11<=s00;
b11<=a(1) and b(3);
l11:fullAdder port map(x=>a11,y=>b11,cin=>c01,s=>s11,cout=>c11);

a12<=s01;
b12<=a(0) and b(3);
cin12<=a(1) and b(2);
l12:fullAdder port map(x=>a12,y=>b12,cin=>cin12,s=>s12,cout=>c12);

a13<=a(1) and b(1);
b13<=a(2) and b(0);
l13:fullAdder port map(x=>a13,y=>b13,cin=>'0',s=>s13,cout=>c13);


a20<=a(3) and b(3);
b20<=c10;
l20:fullAdder port map(x=>a20,y=>b20,cin=>c21,s=>s20,cout=>c20);

a21<=s10;
b21<=c11;
l21:fullAdder port map(x=>a21,y=>b21,cin=>c22,s=>s21,cout=>c21);

a22<=s11;
b22<=c12;
l22:fullAdder port map(x=>a22,y=>b22,cin=>c23,s=>s22,cout=>c22);

a23<=s12;
b23<=c13;
l23:fullAdder port map(x=>a23,y=>b23,cin=>c24,s=>s23,cout=>c23);

a24<=a(0) and b(2);
b24<=s13;
l24:fullAdder port map(x=>a24,y=>b24,cin=>c25,s=>s24,cout=>c24);

a25<=a(1) and b(0);
b25<=a(0) and b(1);
l25:fullAdder port map(x=>a25,y=>b25,cin=>'0',s=>s25,cout=>c25);

mul<=c20 & s20 & s21 & s22 & s23 & s24 & s25 & (a(0) and b(0));

end Behavioral;
