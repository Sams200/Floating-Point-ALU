library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity aluFloat is
Port (
	clk : in STD_LOGIC;
	start:in std_logic;
	reset:in std_logic;
	op : in STD_LOGIC;
	
	num1 : in STD_LOGIC_VECTOR (31 downto 0);
	num2 : in STD_LOGIC_VECTOR (31 downto 0);
	
	res : out STD_LOGIC_VECTOR (31 downto 0);
	working:out std_logic;
	infinityFlag:out std_logic;
	zeroFlag:out std_logic;
	nanFlag:out std_logic
);
end aluFloat;

architecture Behavioral of aluFloat is

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

signal selectSign1,selectExponent1,selectMantissa1:std_logic_vector(1 downto 0);
signal selectSign2,selectExponent2,selectMantissa2:std_logic_vector(1 downto 0);

signal outSign1,outExponent1,outMantissa1:std_logic_vector(31 downto 0);
signal outSign2,outExponent2,outMantissa2:std_logic_vector(31 downto 0);

signal sign1A,sign1B,sign1C,sign1D,exponent1A,exponent1B,exponent1C,exponent1D,mantissa1A,mantissa1B,mantissa1C,mantissa1D:std_logic_vector(31 downto 0):=x"00000000";
signal sign2A,sign2B,sign2C,sign2D,exponent2A,exponent2B,exponent2C,exponent2D,mantissa2A,mantissa2B,mantissa2C,mantissa2D:std_logic_vector(31 downto 0):=x"00000000";

component register32bitW8x1Mux is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           C : in STD_LOGIC_VECTOR (31 downto 0);
           D : in STD_LOGIC_VECTOR (31 downto 0);
           E : in STD_LOGIC_VECTOR (31 downto 0);
           F : in STD_LOGIC_VECTOR (31 downto 0);
           G : in STD_LOGIC_VECTOR (31 downto 0);
           H : in STD_LOGIC_VECTOR (31 downto 0);
           S: in std_logic_vector(2 downto 0);
           write : in STD_LOGIC;
           clk : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (31 downto 0));
end component;
signal writeSignRes,writeExponentRes,writeMantissaRes:std_logic;
signal selectSignRes,selectExponentRes,selectMantissaRes:std_logic_vector(2 downto 0);
signal outSignRes,outExponentRes,outMantissaRes:std_logic_vector(31 downto 0);
signal signRA,signRB,signRC,signRD,signRE,signRF,signRG,signRH:std_logic_vector(31 downto 0):=x"00000000";
signal exponentRA,exponentRB,exponentRC,exponentRD,exponentRE,exponentRF,exponentRG,exponentRH:std_logic_vector(31 downto 0):=x"00000000";
signal mantissaRA,mantissaRB,mantissaRC,mantissaRD,mantissaRE,mantissaRF,mantissaRG,mantissaRH:std_logic_vector(31 downto 0):=x"00000000";

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
signal alu32bitCout:std_logic;

component comparator32bit is
    Port ( numA : in STD_LOGIC_vector(31 downto 0);
           numB : in STD_LOGIC_vector(31 downto 0);
           eq : out STD_LOGIC;
           greater : out STD_LOGIC);
end component;
signal comparator1InA,comparator1InB:std_logic_vector(31 downto 0);
signal comparator1Eq,comparator1Greater:std_logic;
signal comparator1Select:std_logic_vector(2 downto 0);
signal comparator2InA,comparator2InB:std_logic_vector(31 downto 0);
signal comparator2Eq,comparator2Greater:std_logic;
signal comparator2Select:std_logic_vector(2 downto 0);

component multiplier32bit is
    Port ( numA : in STD_LOGIC_VECTOR (31 downto 0);
           numB : in STD_LOGIC_VECTOR (31 downto 0);
           result : out STD_LOGIC_VECTOR (63 downto 0));
end component;
signal multiplierInA,multiplierInB:std_logic_vector(31 downto 0);
signal multiplierResult:std_logic_vector(63 downto 0);

begin

multiplier:multiplier32bit port map(
	numA=>multiplierInA,
	numB=>multiplierInB,
	result=>multiplierResult
);
multiplierInA<=outMantissa1;
multiplierInB<=outMantissa2;
-----------------------------------------
comparator1:comparator32bit port map(
	numA=>comparator1InA,
	numB=>comparator1InB,
	eq=>comparator1Eq,
	greater=>comparator1Greater
);
comparator2:comparator32bit port map(
	numA=>comparator2InA,
	numB=>comparator2InB,
	eq=>comparator2Eq,
	greater=>comparator2Greater
);
-----------------------------------------
alu:alu32bit port map(
	numA=>alu32bitA,
	numB=>alu32bitB,
	op=>alu32bitOp,
	output=>alu32bitOut,
	cout=>alu32bitCout
);
--====================================
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
regSignR:register32bitW8x1Mux port map(
	clk=>clk,
	write=>writeSignRes,
	S=>selectSignRes,
	output=>outSignRes,
	A=> signRA,
	B=> signRB,
	C=> signRC,
	D=> signRD,
	E=> signRE,
	F=> signRF,
	G=> signRG,
	H=> signRH
);

regExpR:register32bitW8x1Mux port map(
	clk=>clk,
	write=>writeExponentRes,
	S=>selectExponentRes,
	output=>outExponentRes,
	A=> exponentRA,
	B=> exponentRB,
	C=> exponentRC,
	D=> exponentRD,
	E=> exponentRE,
	F=> exponentRF,
	G=> exponentRG,
	H=> exponentRH
);

regManR:register32bitW8x1Mux port map(
	clk=>clk,
	write=>writeMantissaRes,
	S=>selectMantissaRes,
	output=>outMantissaRes,
	A=> mantissaRA,
	B=> mantissaRB,
	C=> mantissaRC,
	D=> mantissaRD,
	E=> mantissaRE,
	F=> mantissaRF,
	G=> mantissaRG,
	H=> mantissaRH
);

--comparator1 mux
process(comparator1Select,outExponent1,outExponent2,outMantissa1,outMantissa2,outMantissaRes,
	outExponentRes)
begin
	case comparator1Select is
	when "000"=>
		comparator1InA<=x"000000" & outExponent1(7 downto 0);
		comparator1InB<=x"000000" & x"FF";
		
	when "001"=>
		comparator1InA<=x"000000" & outExponent2(7 downto 0);
		comparator1InB<=x"000000" & x"FF";
		
	when "010"=>
		comparator1InA<='0' & outExponent1(7 downto 0) & outMantissa1(30 downto 8);
		comparator1InB<=x"00000000";
		
	when "011"=>
		comparator1InA<=outExponent1;
		comparator1InB<=outExponent2;
		
	when "100"=>
		comparator1InA<=outExponentRes;
		comparator1InB<=x"00000100";
	when others=>
		comparator1InA<=x"00000000";
		comparator1InB<=x"00000001";
	end case;
end process;
--=======================

--comparator2 mux
process(comparator2Select,outExponent1,outExponent2,outMantissa1,outMantissa2,outMantissaRes,
	outExponentRes)
begin
	case comparator2Select is
	when "000"=>
		comparator2InA<="0" & x"00" & outMantissa1(30 downto 8);
		comparator2InB<=x"00000000";
		
	when "001"=>
		comparator2InA<="0" & x"00" & outMantissa2(30 downto 8);
		comparator2InB<=x"00000000";
		
	when "010"=>
		comparator2InA<='0' & outExponent2(7 downto 0) & outMantissa2(30 downto 8);
		comparator2InB<=x"00000000";
		
	when "011"=>
		comparator2InA<=outMantissa1;
		comparator2InB<=outMantissa2;
		
	when "100"=>
		comparator2InA<=outExponentRes;
		comparator2InB<=x"000001FF";
		
	when "101"=>
		comparator2InA<=x"00000100";
		comparator2InB<=outExponentRes;
	when others=>
		comparator2InA<=x"00000000";
		comparator2InB<=x"00000001";
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
		alu32bitA<=outExponent1;
		alu32bitB<=outExponent2;

	when "110"=>
		alu32bitA<=outExponentRes;
		alu32bitB<=x"0000017F"; -- padding and 127 
	when others=>
		alu32bitA<=x"00000000";
		alu32bitB<=x"00000000";
	end case;
end process;

--============================================
sign1A<=x"0000000" & "000" & num1(31);

exponent1A<=x"000001" & num1(30 downto 23);
exponent1B<=alu32bitOut;

mantissa1A<='1' & num1(22 downto 0) & x"00";
mantissa1B<='0' & outMantissa1(31 downto 1);
--================================

sign2A<=x"0000000" & "000" & num2(31);

exponent2A<=x"000001" & num2(30 downto 23);
exponent2B<=alu32bitOut;

mantissa2A<='1' & num2(22 downto 0) & x"00";
mantissa2B<='0' & outMantissa2(31 downto 1);
--===========================

signRA<=x"00000000";
signRB<=x"FFFFFFFF";
signRC<=outSign1 xor outSign2;
signRD<=outSign1;
signRE<=outSign2;

exponentRA<=outExponent1;
exponentRB<=outExponent2;
exponentRC<=x"00000000";
exponentRD<=x"FFFFFFFF";
exponentRE<=alu32bitOut;

mantissaRA<=outMantissa1;
mantissaRB<=outMantissa2;
mantissaRC<=x"00000000";
mantissaRD<=x"FFFFFFFF";
mantissaRE<=alu32bitOut;
mantissaRF<='0' & outMantissaRes(31 downto 1);
mantissaRG<=outMantissaRes(30 downto 0) & '0';
mantissaRH<=multiplierResult(62 downto 31);

--============================================
res(31)<=outSignRes(0);
res(30 downto 23)<=outExponentRes(7 downto 0);
res(22 downto 0)<=outMantissaRes(30 downto 8);

controlUnit:entity work.controlUnit port map(
	clk=>clk,
	reset=>reset,
	start=>start,
	op=>op,
	
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
	
	outSign1=>outSign1(0),
	outSign2=>outSign2(0),
	outSignRes=>outSignRes(0),
	outMantissaRes31=>outMantissaRes(31),
	
	comparator1Select=>comparator1Select,
	comparator1Eq=>comparator1Eq,
	comparator1Greater=>comparator1Greater,
	
	comparator2Select=>comparator2Select,
	comparator2Eq=>comparator2Eq,
	comparator2Greater=>comparator2Greater,
	
	alu32bitOp=>alu32bitOp,
	alu32bitSelect=>alu32bitSelect,
	alu32bitCout=>alu32bitCout,
	
	infinityFlag=>infinityFlag,
	zeroFlag=>zeroFlag,
	nanFlag=>nanFlag,
	
	working=>working
);
end Behavioral;
