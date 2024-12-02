----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2024 12:57:02 PM
-- Design Name: 
-- Module Name: aluFloat - Behavioral
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
use IEEE.std_logic_unsigned.all;



entity aluFloat is
    Port ( clk : in STD_LOGIC;
           num1 : in STD_LOGIC_VECTOR (31 downto 0);
           num2 : in STD_LOGIC_VECTOR (31 downto 0);
           op : in STD_LOGIC;
           start:in std_logic;
           res : out STD_LOGIC_VECTOR (31 downto 0);
           working:out std_logic);
end aluFloat;

architecture Behavioral of aluFloat is

component adderFloat is
    Port ( clk : in STD_LOGIC;
           reset:in STD_LOGIC;
           start:in std_logic;
           num1:in std_logic_vector(31 downto 0);
           num2:in std_logic_vector(31 downto 0);
           res:out std_logic_vector(31 downto 0);
           dbState:out std_logic_vector(3 downto 0);
           working : out STD_LOGIC);
end component;
signal resAdd:std_logic_vector(31 downto 0);
signal workingAdd:std_logic;

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
signal resMul:std_logic_vector(31 downto 0);
signal workingMul:std_logic;

signal startAdd,startMul:std_logic;
type state_type is (start_state,idle_state);
signal state:state_type;
begin




adder:adderFloat port map(
	clk=>clk, 
	num1=>num1,
	num2=>num2,
	res=>resAdd,
	reset=>'0',
	start=>startAdd
);
                            
mul:multiplierFloat port map(
	clk=>clk, 
	num1=>num1, 
	num2=>num2, 
	res=>resMul,
	reset=>'0',
	start=>startMul,
	working=>workingMul
);

startAdd<=start and (not op);
startMul<=start and op;

process(op,resAdd,workingAdd,resMul,workingMul)
begin
    if (op='0') then
        res<=resAdd;
        working<=workingAdd;
    else
        res<=resMul;   
        working<=workingMul;
    end if;
end process;

end Behavioral;
