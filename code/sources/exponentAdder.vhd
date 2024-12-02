----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2024 09:09:41 PM
-- Design Name: 
-- Module Name: exponentAdder - Behavioral
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
use ieee.std_logic_unsigned.all;

entity exponentAdder is
    Port ( exponent1 : in STD_LOGIC_VECTOR (31 downto 0);
           exponent2 : in STD_LOGIC_VECTOR (31 downto 0);
           result: out std_logic_vector(31 downto 0));
end exponentAdder;

architecture Behavioral of exponentAdder is

begin

result<=exponent1+exponent2-127;
end Behavioral;
