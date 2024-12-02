----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2024 08:53:50 PM
-- Design Name: 
-- Module Name: multiplierFloat - Behavioral
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

entity multiplierFloat is
    Port ( clk : in STD_LOGIC;
		   reset:in STD_LOGIC;
		   start:in std_logic;
		   num1:in std_logic_vector(31 downto 0);
		   num2:in std_logic_vector(31 downto 0);
		   res:out std_logic_vector(31 downto 0);
		   dbState:out std_logic_vector(3 downto 0);
		   working : out STD_LOGIC);
end multiplierFloat;

architecture Behavioral of multiplierFloat is

component register32bitW4x1Mux is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           C : in STD_LOGIC_VECTOR (31 downto 0);
           D : in STD_LOGIC_VECTOR (31 downto 0);
           S: in std_logic_vector(1 downto 0);
           write : in STD_LOGIC;
           clk : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (31 downto 0));
end component;
signal writeSign1,writeExponent1,writeMantissa1:std_logic;
signal writeSign2,writeExponent2,writeMantissa2:std_logic;
signal writeSignRes,writeExponentRes,writeMantissaRes:std_logic;

signal selectSign1,selectExponent1,selectMantissa1:std_logic_vector(1 downto 0);
signal selectSign2,selectExponent2,selectMantissa2:std_logic_vector(1 downto 0);
signal selectSignRes,selectExponentRes,selectMantissaRes:std_logic_vector(1 downto 0);

signal outSign1,outExponent1,outMantissa1:std_logic_vector(31 downto 0);
signal outSign2,outExponent2,outMantissa2:std_logic_vector(31 downto 0);
signal outSignRes,outExponentRes:std_logic_vector(31 downto 0);

signal sign1A,sign1B,sign1C,sign1D,exponent1A,exponent1B,exponent1C,exponent1D,mantissa1A,mantissa1B,mantissa1C,mantissa1D:std_logic_vector(31 downto 0):=x"00000000";
signal sign2A,sign2B,sign2C,sign2D,exponent2A,exponent2B,exponent2C,exponent2D,mantissa2A,mantissa2B,mantissa2C,mantissa2D:std_logic_vector(31 downto 0):=x"00000000";
signal signRA,signRB,signRC,signRD,exponentRA,exponentRB,exponentRC,exponentRD:std_logic_vector(31 downto 0):=x"00000000";

component register64bitW4x1Mux is
    Port ( A : in STD_LOGIC_VECTOR (63 downto 0);
           B : in STD_LOGIC_VECTOR (63 downto 0);
           C : in STD_LOGIC_VECTOR (63 downto 0);
           D : in STD_LOGIC_VECTOR (63 downto 0);
           S: in std_logic_vector(1 downto 0);
           write : in STD_LOGIC;
           clk : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (63 downto 0));
end component;
signal mantissaRA,mantissaRB,mantissaRC,mantissaRD:std_logic_vector(63 downto 0):=x"0000000000000000";
signal outMantissaRes:std_logic_vector(63 downto 0):=x"0000000000000000";
-----------------------------------------------------

component exponentAdder is
    Port ( exponent1 : in STD_LOGIC_VECTOR (31 downto 0);
           exponent2 : in STD_LOGIC_VECTOR (31 downto 0);
           result: out std_logic_vector(31 downto 0));
end component;
signal exponentAdder1In,exponentAdder2In,exponentAdderResult:std_logic_vector(31 downto 0);
--------------------------------------------------------

component comparator64bit is
    Port ( numA : in STD_LOGIC_vector(63 downto 0);
           numB : in STD_LOGIC_vector(63 downto 0);
           eq : out STD_LOGIC;
           greater : out STD_LOGIC);
end component;
signal comparatorA,comparatorB:std_logic_vector(63 downto 0);
signal comparatorEq,comparatorGreater:std_logic;
signal comparatorSelect:std_logic_vector(2 downto 0);
-----------------------------------------------------------

component multiplier32bit is
    Port ( numA : in STD_LOGIC_VECTOR (31 downto 0);
           numB : in STD_LOGIC_VECTOR (31 downto 0);
           result : out STD_LOGIC_VECTOR (63 downto 0));
end component;
signal multiplierInA,multiplierInB:std_logic_vector(31 downto 0);
signal multiplierResult:std_logic_vector(63 downto 0);
----------------------------------------------------------------------



begin

--============================================
regSign1:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeSign1,
	S=>selectSign1,
	output=>outSign1,
	A=> sign1A,
	B=> sign1B,
	C=> sign1C,
	D=> sign1D
);

regExp1:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeExponent1,
	S=>selectExponent1,
	output=>outExponent1,
	A=> exponent1A,
	B=> exponent1B,
	C=> exponent1C,
	D=> exponent1D
);

regMan1:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeMantissa1,
	S=>selectMantissa1,
	output=>outMantissa1,
	A=> mantissa1A,
	B=> mantissa1B,
	C=> mantissa1C,
	D=> mantissa1D
);
--============================================

--============================================
regSign2:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeSign2,
	S=>selectSign2,
	output=>outSign2,
	A=> sign2A,
	B=> sign2B,
	C=> sign2C,
	D=> sign2D
);

regExp2:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeExponent2,
	S=>selectExponent2,
	output=>outExponent2,
	A=> exponent2A,
	B=> exponent2B,
	C=> exponent2C,
	D=> exponent2D
);

regMan2:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeMantissa2,
	S=>selectMantissa2,
	output=>outMantissa2,
	A=> mantissa2A,
	B=> mantissa2B,
	C=> mantissa2C,
	D=> mantissa2D
);
--============================================

--============================================
regSignR:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeSignRes,
	S=>selectSignRes,
	output=>outSignRes,
	A=> signRA,
	B=> signRB,
	C=> signRC,
	D=> signRD
);

regExpR:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeExponentRes,
	S=>selectExponentRes,
	output=>outExponentRes,
	A=> exponentRA,
	B=> exponentRB,
	C=> exponentRC,
	D=> exponentRD
);

regManR:register64bitW4x1Mux port map(
	clk=>clk,
	write=>writeMantissaRes,
	S=>selectMantissaRes,
	output=>outMantissaRes,
	A=> mantissaRA,
	B=> mantissaRB,
	C=> mantissaRC,
	D=> mantissaRD
);
-----------------------------------

expAdder:exponentAdder port map(
	exponent1=>exponentAdder1In,
	exponent2=>exponentAdder2In,
	result=>exponentAdderResult
);
exponentAdder1In<=outExponent1;
exponentAdder2In<=outExponent2;
---------------------------------------

comparator:comparator64bit port map(
	numA=>comparatorA,
	numB=>comparatorB,
	eq=>comparatorEq,
	greater=>comparatorGreater
);
-----------------------------------

multiplier:multiplier32bit port map(
	numA=>multiplierInA,
	numB=>multiplierInB,
	result=>multiplierResult
);
multiplierInA<=outMantissa1;
multiplierInB<=outMantissa2;
-----------------------------------

controlUnit:entity work.fpMultiplierControlUnit port map(
	clk=>clk,
	reset=>reset,
	comparatorEq=>comparatorEq,
	comparatorGreater=>comparatorGreater,
	outMantissaRes63=>outMantissaRes(63),
	
	start=>start,
	
	writeSign1=>writeSign1,
	writeSign2=>writeSign2,
	writeSignRes=>writeSignRes,
	
	writeExponent1=>writeExponent1,
	writeExponent2=>writeExponent2,
	writeExponentRes=>writeExponentRes,
	
	writeMantissa1=>writeMantissa1,
	writeMantissa2=>writeMantissa2,
	writeMantissaRes=>writeMantissaRes,
	
	selectSign1=>selectSign1,
	selectExponent1=>selectExponent1,
	selectMantissa1=>selectMantissa1,
	
	selectSign2=>selectSign2,
	selectExponent2=>selectExponent2,
	selectMantissa2=>selectMantissa2,
	
	selectSignRes=>selectSignRes,
	selectExponentRes=>selectExponentRes,
	selectMantissaRes=>selectMantissaRes,
	
	dbState=>dbState,
	working=>working,
	comparatorSelect=>comparatorSelect
);


--comparator mux
process(comparatorSelect,outMantissaRes,outExponentRes)
begin
	case comparatorSelect is
	when "000"=>
		comparatorA<=outMantissaRes;
		comparatorB<=x"0000000000000000";

	when "001"=>
		comparatorA<=x"00000000" & outExponentRes;
		comparatorB<=x"00000000" & x"000002FF";
		
	when "010"=>
		comparatorB<=x"00000000" & outExponentRes;
		comparatorA<=x"00000000" & x"00000200";
		
	when others=>
		comparatorA<=x"0000000000000000";
		comparatorB<=x"0000000000000000";
	end case;
end process;
------------------------------------------

sign1A<=x"0000000" & "000" & num1(31);

exponent1A<=x"000000" & num1(30 downto 23);

mantissa1A<='1' & num1(22 downto 0) & x"00";
--------------------------------------------

sign2A<=x"0000000" & "000" & num2(31);

exponent2A<=x"000000" & num2(30 downto 23);

mantissa2A<='1' & num2(22 downto 0) & x"00";
----------------------------------------------

signRA<=outSign1 xor outSign2;
signRB<=x"00000000";

exponentRA<=exponentAdderResult;
exponentRB<=x"00000000";

exponentRD<=x"FFFFFFFF";

mantissaRA<=multiplierResult;
--mantissaRB<=outMantissaRes(62 downto 0) & '0';
mantissaRC<=x"0000000000000000";
mantissaRD<=x"FFFFFFFFFFFFFFFF";


res(31)<=outSignRes(0);
res(30 downto 23)<=outExponentRes(7 downto 0);
res(22 downto 0)<=outMantissaRes(61 downto 39);

end Behavioral;
