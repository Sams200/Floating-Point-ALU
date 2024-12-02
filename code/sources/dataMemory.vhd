----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2024 12:46:20 PM
-- Design Name: 
-- Module Name: dataMemory - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity dataMemory is
    Port ( clk : in STD_LOGIC;
           reset:in STD_LOGIC;
           dataOut1 : out STD_LOGIC_VECTOR (31 downto 0);
           dataOut2 : out STD_LOGIC_VECTOR (31 downto 0));
end dataMemory;

architecture Behavioral of dataMemory is

type rom is array(0 to 255) of std_logic_vector(31 downto 0);

signal dataMemory1:rom:=
(--write data here
b"11111111111111111111111111111111",
b"11110000111100001111000011110000",

others=> b"00000000000000000000000000000000"
);

signal dataMemory2:rom:=
(--write data here
b"10101010101011101011101010101011",
b"00110011001100110011001100110011",

others=> b"00000000000000000000000000000000"
);

signal pc:std_logic_vector(7 downto 0);

begin

--program counter
process(clk,reset,pc)
begin
    if(reset='1') then
        pc<=x"00";
    elsif (clk'event and clk='1') then
        pc<=pc+1;
    end if;
end process;

dataOut1<=dataMemory1(conv_integer(pc));
dataOut2<=dataMemory2(conv_integer(pc));
end Behavioral;
