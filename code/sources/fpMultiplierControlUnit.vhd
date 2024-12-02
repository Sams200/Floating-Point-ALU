----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2024 10:22:16 PM
-- Design Name: 
-- Module Name: fpMultiplierControlUnit - Behavioral
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

entity fpMultiplierControlUnit is
	Port (
		clk:in std_logic;
		reset:in std_logic;
		
		comparatorEq:in std_logic;
		comparatorGreater:in std_logic;
		outMantissaRes63:in std_logic;
		
		start:in std_logic;
		
		writeSign1:out std_logic;
		writeSign2:out std_logic;
		writeSignRes:out std_logic;
		
		writeExponent1:out std_logic;
		writeExponent2:out std_logic;
		writeExponentRes:out std_logic;
		
		writeMantissa1:out std_logic;
		writeMantissa2:out std_logic;
		writeMantissaRes:out std_logic;
		
		selectSign1:out std_logic_vector(1 downto 0);
		selectExponent1:out std_logic_vector(1 downto 0);
		selectMantissa1:out std_logic_vector(1 downto 0);
		
		selectSign2:out std_logic_vector(1 downto 0);
		selectExponent2:out std_logic_vector(1 downto 0);
		selectMantissa2:out std_logic_vector(1 downto 0);
		
		selectSignRes:out std_logic_vector(1 downto 0);
		selectExponentRes:out std_logic_vector(1 downto 0);
		selectMantissaRes:out std_logic_vector(1 downto 0);
		
		dbState:out std_logic_vector(3 downto 0);
		working:out std_logic;
		comparatorSelect:out std_logic_vector(2 downto 0)
	);
end fpMultiplierControlUnit;

architecture Behavioral of fpMultiplierControlUnit is

type state_type is (idle_state,add_state,multiply_state,align_state,verify_overflow_state,verify_underflow_state);
signal state:state_type;

begin

--next state
process(clk,reset)
begin

if(reset='1') then
	state<=idle_state;
elsif(clk'event and clk='1') then

case state is
	when idle_state=>
		if(start='1') then
			state<=add_state;
		else
			state<=idle_state;
		end if;
		
	when add_state=>
		state<=multiply_state;
	
	when multiply_state=>
		state<=align_state;
		
	when align_state=>
		if(comparatorEq='1') then
			state<=idle_state;
		else
			--if(outMantissaRes63='0') then
				--state<=align_state;
			--else
				state<=verify_overflow_state;
			--end if;
		end if;
	
	when verify_overflow_state=>
		state<=verify_underflow_state;
		
	when verify_underflow_state=>
		state<=idle_state;
		
	when others=>
		state<=idle_state;
end case;
	
end if;
end process;

--main control
process(state,comparatorEq,comparatorGreater,outMantissaRes63)
begin

writeSign1<='0';
writeSign2<='0';
writeSignRes<='0';

writeExponent1<='0';
writeExponent2<='0';
writeExponentRes<='0';

writeMantissa1<='0';
writeMantissa2<='0';
writeMantissaRes<='0';
working<='1';

case state is
	when idle_state=>
		dbState<="0000";
		working<='0';
		
		--read inputs
		writeSign1<='1';
		selectSign1<="00";
		writeExponent1<='1';
		selectExponent1<="00";
		writeMantissa1<='1';
		selectMantissa1<="00";
		
		writeSign2<='1';
		selectSign2<="00";
		writeExponent2<='1';
		selectExponent2<="00";
		writeMantissa2<='1';
		selectMantissa2<="00";
		
	when add_state=>
		dbState<="0001";
		
		--signRes<=sign1 xor sign2
		writeSignRes<='1';
		selectSignRes<="00";
		
		--exponentRes<=exponent1+exponent2-127
		writeExponentRes<='1';
		selectExponentRes<="00";
		
	when multiply_state=>
		dbState<="0010";
		
		writeMantissaRes<='1';
		selectMantissaRes<="00";
		
	when align_state=>
		dbState<="0100";
		
		comparatorSelect<="000"; --mantissaRess [] x"00000000"
		
		if(comparatorEq='1') then
			--mantissa is 0 so make exponent 0
			
			writeExponentRes<='1';
			selectExponentRes<="01";
		else
			--if(outMantissaRes63='0') then
				--shift left mantissa until we find the first 1 on the msb
				--writeMantissaRes<='1';
				--selectMantissaRes<="01";
			--end if;
		end if;
		
	when verify_overflow_state=>
		--check for exponent overflow
		dbState<="1000";
		comparatorSelect<="001";
		
		if(comparatorGreater='1') then
			--exponent overflow +- infinity
			writeExponentRes<='1';
			selectExponentRes<="11";
			
			writeMantissaRes<='1';
			selectMantissaRes<="10";
		end if;
		
	when verify_underflow_state=>
		--check for exponent underflow
		dbState<="1001";
		comparatorSelect<="010";
		
		if(comparatorGreater='0' and comparatorEq='0') then
			writeExponentRes<='1';
			selectExponentRes<="01";
			
			writeMantissaRes<='1';
			selectMantissaRes<="10";
		end if;
	when others=>
end case;
end process;

end Behavioral;
