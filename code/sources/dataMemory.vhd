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
b"01000001100000010010011100011111", --16.144102 4181271f
b"01000000000001010100000110011100", --2.082129
b"01000001100100011100111101010010", --18.226231
b"01000010100011100101111110010111", --71.186699
b"01000010000000001000000101000001", --32.126225
b"00000000000000000000000000000000", --0

others=> b"00000000000000000000000000000000"
);

signal dataMemory2:rom:=
(--write data here
b"01000000001101110001001010010001", --2.860508 40371291
b"01000010100101000001100000101100", --74.047211
b"01000010101011001101000100111111", --86.408684
b"01000001110101011011111100110010", --26.718357
b"0_11111111_00000000000000000000000", --+inf
b"11000010010011101110001001110101", -- -51.721149

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
