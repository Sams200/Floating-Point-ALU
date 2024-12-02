library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adderFloat is
    Port ( clk : in STD_LOGIC;
           reset:in STD_LOGIC;
           start:in std_logic;
           num1:in std_logic_vector(31 downto 0);
           num2:in std_logic_vector(31 downto 0);
           res:out std_logic_vector(31 downto 0);
           dbState:out std_logic_vector(3 downto 0);
           working : out STD_LOGIC);
end adderFloat;


architecture Behavioral of adderFloat is

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

component comparator32bit is
    Port ( numA : in STD_LOGIC_vector(31 downto 0);
           numB : in STD_LOGIC_vector(31 downto 0);
           eq : out STD_LOGIC;
           greater : out STD_LOGIC);
end component;
signal comparatorInA,comparatorInB:std_logic_vector(31 downto 0);
signal comparatorEq,comparatorGreater:std_logic;
signal comparatorSelect:std_logic_vector(2 downto 0);

component alu32bit is
Port ( 		
		numA : in STD_LOGIC_VECTOR (31 downto 0);
	   	numB : in STD_LOGIC_VECTOR (31 downto 0);
	   	op : in STD_LOGIC_vector(1 downto 0);
	   	output : out STD_LOGIC_VECTOR (31 downto 0);
	   	cout: out std_logic);
end component;
signal alu32bitA:std_logic_vector(31 downto 0);
signal alu32bitB:std_logic_vector(31 downto 0);
signal alu32bitOp:std_logic_vector(1 downto 0);
signal alu32bitOut:std_logic_vector(31 downto 0);
signal alu32bitSelect:std_logic_vector(2 downto 0);



signal writeSign1,writeExponent1,writeMantissa1:std_logic;
signal writeSign2,writeExponent2,writeMantissa2:std_logic;
signal writeSignRes,writeExponentRes,writeMantissaRes:std_logic;

signal selectSign1,selectExponent1,selectMantissa1:std_logic_vector(1 downto 0);
signal selectSign2,selectExponent2,selectMantissa2:std_logic_vector(1 downto 0);
signal selectSignRes,selectExponentRes,selectMantissaRes:std_logic_vector(1 downto 0);

signal outSign1,outExponent1,outMantissa1:std_logic_vector(31 downto 0);
signal outSign2,outExponent2,outMantissa2:std_logic_vector(31 downto 0);
signal outSignRes,outExponentRes,outMantissaRes:std_logic_vector(31 downto 0);

signal sign1A,sign1B,sign1C,sign1D,exponent1A,exponent1B,exponent1C,exponent1D,mantissa1A,mantissa1B,mantissa1C,mantissa1D:std_logic_vector(31 downto 0):=x"00000000";
signal sign2A,sign2B,sign2C,sign2D,exponent2A,exponent2B,exponent2C,exponent2D,mantissa2A,mantissa2B,mantissa2C,mantissa2D:std_logic_vector(31 downto 0):=x"00000000";
signal signRA,signRB,signRC,signRD,exponentRA,exponentRB,exponentRC,exponentRD,mantissaRA,mantissaRB,mantissaRC,mantissaRD:std_logic_vector(31 downto 0):=x"00000000";



begin

comparator:comparator32bit port map(
	numA=>comparatorInA,
	numB=>comparatorInB,
	eq=>comparatorEq,
	greater=>comparatorGreater
);

adder:alu32bit port map(
	numA=>alu32bitA,
	numB=>alu32bitB,
	op=>alu32bitOp,
	output=>alu32bitOut
);

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

regManR:register32bitW4x1Mux port map(
	clk=>clk,
	write=>writeMantissaRes,
	S=>selectMantissaRes,
	output=>outMantissaRes,
	A=> mantissaRA,
	B=> mantissaRB,
	C=> mantissaRC,
	D=> mantissaRD
);

controlUnit:entity work.fpAdderControlUnit port map(
	clk=>clk,
	reset=>reset,
	
	comparatorEq=>comparatorEq,
	comparatorGreater=>comparatorGreater,
	
	outSign1_0=>outSign1(0),
	outSign2_0=>outSign2(0),
	outMantissaRes24=>outMantissaRes(24),
	outMantissaRes23=>outMantissaRes(23),
	
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
	
	comparatorSelect=>comparatorSelect,
	alu32bitSelect=>alu32bitSelect,
	alu32bitOp=>alu32bitOp
);


--comparator mux
process(comparatorSelect,outExponent1,outExponent2,outMantissa1,outMantissa2,outMantissaRes)
begin
	case comparatorSelect is
	when "000"=>
		comparatorInA<=outExponent1;
		comparatorInB<=outExponent2;
		
	when "001"=>
		comparatorInA<=outMantissa1;
		comparatorInB<=outMantissa2;
		
	when "010"=>
		comparatorInA<=outMantissaRes;
		comparatorInB<=x"00000000";
		
	when "011"=>
		comparatorInA<=outExponentRes;
		comparatorInB<=x"000001FF";
		
	when "100"=>
		comparatorInA<=outExponentRes;
		comparatorInB<=x"00000100";
	when others=>
		comparatorInA<=x"00000000";
		comparatorInB<=x"00000000";
	end case;
end process;
--=======================

--mux alu
process(alu32bitSelect,outExponent1,outExponent2,outMantissa1,outMantissa2,outExponentRes)
begin
	case alu32bitSelect is
	when "000"=>
		alu32bitA<=outExponent2;
		alu32bitB<=x"00000000";
		
	when "001"=>
		alu32bitA<=outExponent1;
		alu32bitB<=x"00000000";
		
	when "010"=>
		alu32bitA<=outMantissa1;
		alu32bitB<=outMantissa2;
		
	when "011"=>
		alu32bitA<=outMantissa2;
		alu32bitB<=outMantissa1;
		
	when "100"=>
		alu32bitA<=outExponentRes;
		alu32bitB<=x"00000000";
		
	when "101"=>
		alu32bitA<=x"00000000";
		alu32bitB<=x"00000000";

	when others=>
		alu32bitA<=x"00000000";
		alu32bitB<=x"00000000";
	end case;
end process;

--============================================

--sign1<=outSign1(0);
sign1A<=x"0000000" & "000" & num1(31);

--exponent1<=outExponent1(7 downto 0);
exponent1A<=x"000001" & num1(30 downto 23);
exponent1B<=alu32bitOut;

--mantissa1<=outMantissa1(24 downto 0);
mantissa1A<=x"00" & "1" & num1(22 downto 0);
mantissa1B<='0' & outMantissa1(31 downto 1);
--================================

--sign2<=outSign2(0);
sign2A<=x"0000000" & "000" & num2(31);

--exponent2<=outExponent2(7 downto 0);
exponent2A<=x"000001" & num2(30 downto 23);
exponent2B<=alu32bitOut;

--mantissa2<=outMantissa2(24 downto 0);
mantissa2A<=x"00" & "1" & num2(22 downto 0);
mantissa2B<='0' & outMantissa2(31 downto 1);
--===========================

--signRes<=outSignRes(0);
signRA<=outSign1;
signRB<=outSign2;
signRC<=x"00000000";

--exponentRes<=outExponentRes(7 downto 0);
exponentRA<=outExponent1;
exponentRB<=x"00000000";
exponentRC<=alu32bitOut;
exponentRD<=x"FFFFFFFF";

--mantissaRes<=outMantissaRes(24 downto 0);
mantissaRA<=alu32bitOut;
mantissaRB<='0' & outMantissaRes(31 downto 1);
mantissaRC<=outMantissaRes(30 downto 0) & '0';
mantissaRD<=x"FFFFFFFF";

res(31)<=outSignRes(0);
res(30 downto 23)<=outExponentRes(7 downto 0);
res(22 downto 0)<=outMantissaRes(22 downto 0);



end Behavioral;
