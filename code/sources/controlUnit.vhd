library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity controlUnit is
Port (
	clk : in STD_LOGIC;
	reset: in std_logic;
	start:in std_logic;
	op:in std_logic;
	
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
	
	selectSignRes:out std_logic_vector(2 downto 0);
	selectExponentRes:out std_logic_vector(2 downto 0);
	selectMantissaRes:out std_logic_vector(2 downto 0);
	
	outSign1:in std_logic;
	outSign2:in std_logic;
	outSignRes:in std_logic;
	outMantissaRes31:in std_logic;
	
	comparator1Select:out std_logic_vector(2 downto 0);
	comparator1Eq:in std_logic;
	comparator1Greater:in std_logic;
	
	comparator2Select:out std_logic_vector(2 downto 0);
	comparator2Eq:in std_logic;
	comparator2Greater:in std_logic;
	
	alu32bitOp:out std_logic_vector(1 downto 0);
	alu32bitSelect:out std_logic_vector(2 downto 0);
	alu32bitCout: in std_logic;
	
	infinityFlag:out std_logic;
	zeroFlag:out std_logic;
	nanFlag:out std_logic;
	
	working:out std_logic
);
end controlUnit;

architecture Behavioral of controlUnit is
type state_type is (
	idle_state,

	check_nan_1, check_nan_2,
	check_zero,
	valid_op,
	
	fpAdd_compare,
	fpAdd_add,
	
	
	fpMul_add,
	fpMul_sub127,
	fpMul_mul,
	
	align,
	verify_exponent_overflow,
	verify_exponent_underflow,
	
	writeNan,
	writeInfinityXor,writeInfinityPos,writeInfinityNeg,
	writeZeroXor,writeZeroPos,writeZeroNeg,
	writeNum1,writeNum2
	);
signal state:state_type;

signal infinityPos1,infinityPos2,infinityNeg1,infinityNeg2:std_logic:='0';
signal zeroPos1,zeroPos2,zeroNeg1,zeroNeg2:std_logic:='0';
signal internalFlags:std_logic_vector(8 downto 0);
signal internalOp:std_logic:='0';

signal overflow:std_logic:='0';

begin

internalFlags<=internalOp & infinityPos1 & infinityNeg1 & infinityPos2 & infinityNeg2 &
				zeroPos1 & zeroNeg1 & zeroPos2 & zeroNeg2;
--next state
process(clk,reset)
begin

if(reset='1') then
	state<=idle_state;
elsif(clk'event and clk='1') then

case state is
	when idle_state=>
		internalOp<=op;
		if(start='1') then
			state<=check_nan_1;
		else
			state<=idle_state;
		end if;
		
	when check_nan_1=>
		if(comparator1Eq='1') then
			--exponent is xFF
			if(comparator2Eq='0') then
				--first number is Nan
				state<=writeNan;
			else
				--first number is infinity				
				state<=check_nan_2;
			end if;
		else
			state<=check_nan_2;
		end if;
		
	when check_nan_2=>
		if(comparator1Eq='1') then
			--exponent is xFF
			if(comparator2Eq='0') then
				--second number is Nan
				state<=writeNan;
			else
				--second number is infinity
				state<=check_zero;
			end if;
		else
			state<=check_zero;
		end if;
		
	when writeNan=>
		state<=idle_state;
		
	when check_zero=>
		state<=valid_op;
		
	when valid_op=>
		case internalFlags is
--		internalFlags<=op & infinityPos1 & infinityNeg1 & infinityPos2 & infinityNeg2 &
--				zeroPos1 & zeroNeg1 & zeroPos2 & zeroNeg2;
			when "000000000"=>
				state<=fpAdd_compare;
				
			-- +infinity + x
			when b"0_10_10_00_00"=> -- +inf + +inf
				state<=writeInfinityPos;
			when b"0_10_01_00_00"=> -- +inf + -inf
				state<=writeNan;
			when b"0_10_00_00_10"=> -- +inf + +0
				state<=writeInfinityPos;
			when b"0_10_00_00_01"=> -- +inf + -0
				state<=writeInfinityPos;
			when b"0_10_00_00_00"=> -- +inf + x
				state<=writeInfinityPos;
				
			-- -infinity + x
			when b"0_01_10_00_00"=> -- -inf + +inf
				state<=writeNan;
			when b"0_01_01_00_00"=> -- -inf + -inf
				state<=writeInfinityNeg;
			when b"0_01_00_00_10"=> -- -inf + +0
				state<=writeInfinityNeg;
			when b"0_01_00_00_01"=> -- -inf + -0
				state<=writeInfinityNeg;
			when b"0_01_00_00_00"=> -- -inf + x
				state<=writeInfinityNeg;
				
			-- +0 + x
			when b"0_00_10_10_00"=> -- +0 + +inf
				state<=writeInfinityPos;
			when b"0_00_01_10_00"=> -- +0 + -inf
				state<=writeInfinityNeg;
			when b"0_00_00_10_10"=> -- +0 + +0
				state<=writeZeroPos;
			when b"0_00_00_10_01"=> -- +0 + -0
				state<=writeZeroPos;
			when b"0_00_00_10_00"=> -- +0 + x
				state<=writeNum2;
				
			-- -0 + x
			when b"0_00_10_01_00"=> -- -0 + +inf
				state<=writeInfinityPos;
			when b"0_00_01_01_00"=> -- -0 + -inf
				state<=writeInfinityNeg;
			when b"0_00_00_01_10"=> -- -0 + +0
				state<=writeZeroPos;
			when b"0_00_00_01_01"=> -- -0 + -0
				state<=writeZeroNeg;
			when b"0_00_00_01_00"=> -- -0 + x
				state<=writeNum2;
			
			-- x + special
			when b"0_00_10_00_00"=> -- x + +inf
				state<=writeInfinityPos;
			when b"0_00_01_00_00"=> -- x + -inf
				state<=writeInfinityNeg;
			when b"0_00_00_00_10"=> -- x + +0
				state<=writeNum1;
			when b"0_00_00_00_01"=> -- x + -0
				state<=writeNum1;
				
--		internalFlags<=op & infinityPos1 & infinityNeg1 & infinityPos2 & infinityNeg2 &
--				zeroPos1 & zeroNeg1 & zeroPos2 & zeroNeg2;
			when "100000000"=>
				state<=fpMul_add;
				
			-- +infinity * x
			when b"1_10_10_00_00"=> -- +inf * +inf
				state<=writeInfinityPos;
			when b"1_10_01_00_00"=> -- +inf * -inf
				state<=writeInfinityNeg;
			when b"1_10_00_00_10"=> -- +inf * +0
				state<=writeNan;
			when b"1_10_00_00_01"=> -- +inf * -0
				state<=writeNan;
			when b"1_10_00_00_00"=> -- +inf * x
				state<=writeInfinityXor;
				
			-- -infinity * x
			when b"1_01_10_00_00"=> -- -inf * +inf
				state<=writeInfinityNeg;
			when b"1_01_01_00_00"=> -- -inf * -inf
				state<=writeInfinityPos;
			when b"1_01_00_00_10"=> -- -inf * +0
				state<=writeNan;
			when b"1_01_00_00_01"=> -- -inf * -0
				state<=writeNan;
			when b"1_01_00_00_00"=> -- -inf * x
				state<=writeInfinityXor;
				
			-- +0 * x
			when b"1_00_10_10_00"=> -- +0 * +inf
				state<=writeNan;
			when b"1_00_01_10_00"=> -- +0 * -inf
				state<=writeNan;
			when b"1_00_00_10_10"=> -- +0 * +0
				state<=writeZeroPos;
			when b"1_00_00_10_01"=> -- +0 * -0
				state<=writeZeroNeg;
			when b"1_00_00_10_00"=> -- +0 * x
				state<=writeZeroXor;
				
			-- -0 * x
			when b"1_00_10_01_00"=> -- -0 * +inf
				state<=writeNan;
			when b"1_00_01_01_00"=> -- -0 * -inf
				state<=writeNan;
			when b"1_00_00_01_10"=> -- -0 * +0
				state<=writeZeroNeg;
			when b"1_00_00_01_01"=> -- -0 * -0
				state<=writeZeroPos;
			when b"1_00_00_01_00"=> -- -0 * x
				state<=writeZeroXor;
			
			-- x * special
			when b"1_00_10_00_00"=> -- x * +inf
				state<=writeInfinityXor;
			when b"1_00_01_00_00"=> -- x * -inf
				state<=writeInfinityXor;
			when b"1_00_00_00_10"=> -- x * +0
				state<=writeZeroXor;
			when b"1_00_00_00_01"=> -- x * -0
				state<=writeZeroXor;
				
			when others=>
				state<=writeNan;
		end case;
	
	when fpAdd_compare=>
		if(comparator1Eq='1') then --exponent1=exponent2
			state<=fpAdd_add;
		else
			state<=fpAdd_compare;
		end if;
	
	when fpAdd_add=>
		state<=align;
		
	when fpMul_add=>
		state<=fpMul_sub127;
	
	when fpMul_sub127=>
		state<=fpMul_mul;
		
	when fpMul_mul=>
		state<=align;
		
	when align=>
		if(comparator1Eq='1') then
			if(outSignRes='1') then
				state<=writeZeroNeg;
			else
				state<=writeZeroPos;
			end if;
		else
			state<=verify_exponent_overflow;
		end if;
		
	when verify_exponent_overflow=>
		if(comparator2Greater='1')then
			if(outSignRes='1') then
				state<=writeInfinityNeg;
			else
				state<=writeInfinityPos;
			end if;
		else
			state<=verify_exponent_underflow;
		end if;
		
	when verify_exponent_underflow=>
		if(comparator2Greater='1' or comparator2Eq='1')then
			if(outSignRes='1') then
				state<=writeZeroNeg;
			else
				state<=writeZeroPos;
			end if;
		else
			state<=idle_state;
		end if;
	when others=>
		state<=idle_state;
end case;
end if;
end process;


--main control
process(state,comparator1Eq,comparator2Eq,outSign1,outSign2,comparator1Greater,comparator2Greater,
	overflow, outMantissaRes31,alu32bitCout)
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

comparator1Select<="111";
comparator2Select<="111";

case state is
	when idle_state=>
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
		
		infinityPos1<='0';
		infinityPos2<='0';
		infinityNeg1<='0';
		infinityNeg2<='0';
		
		zeroPos1<='0';
		zeroPos2<='0';
		zeroNeg1<='0';
		zeroNeg2<='0';
		
		overflow<='0';
		
	when check_nan_1=>
		infinityFlag<='0';
		zeroFlag<='0';
		nanFlag<='0';
		
		--check if first number is Nan. If it is, write Nan and perform no operation
		comparator1Select<="000";
		comparator2Select<="000";
		
		infinityPos1<='0';
		infinityNeg1<='0';
		
		if(comparator1Eq='1') then
			--exponent is xFF
			if(comparator2Eq='0') then
				--first number is Nan		
			else
				--first number is infinity
				if(outSign1='0') then
					infinityPos1<='1';
				else
					infinityNeg1<='1';
				end if;
			end if;
		end if;
		
	when check_nan_2=>
	--check if second number is Nan. If it is, write Nan and perform no operation
		comparator1Select<="001";
		comparator2Select<="001";
		
		infinityPos2<='0';
		infinityNeg2<='0';
		
		if(comparator1Eq='1') then
			--exponent is xFF
			if(comparator2Eq='0') then
				--second number is Nan
			else
				--second number is infinity
				if(outSign2='0') then
					infinityPos2<='1';
				else
					infinityNeg2<='1';
				end if;
			end if;
		end if;
		
	
		
	when check_zero=>
		comparator1Select<="010";
		comparator2Select<="010";
		
		zeroPos1<='0';
		zeroNeg1<='0';
		
		if(comparator1Eq='1') then
			if(outSign1='0') then
					zeroPos1<='1';
				else
					zeroNeg1<='1';
				end if;
		end if;
		
		zeroPos2<='0';
		zeroNeg2<='0';
		
		if(comparator2Eq='1') then
			if(outSign2='0') then
					zeroPos2<='1';
				else
					zeroNeg2<='1';
				end if;
		end if;
		
	when valid_op=>
		
	when fpAdd_compare=>
		comparator1Select<="011"; --exponent1 [] exponent2
		
		alu32bitOp<="10"; --increment
		
		if(comparator1Eq = '0') then
			if(comparator1Greater='1') then -- exponent1 > exponent2
				alu32bitSelect<="000"; --exponent2++
				
				writeExponent2<='1';
				selectExponent2<="01"; --alu out
				
				writeMantissa2<='1';
				selectMantissa2<="01"; --mantissa2>>1
			else
				alu32bitSelect<="001"; --exponent1++
				
				writeExponent1<='1';
				selectExponent1<="01"; --alu out
				
				writeMantissa1<='1';
				selectMantissa1<="01"; --mantissa1>>1
			end if;
		end if;
		
	when fpAdd_add=>
		
		writeExponentRes<='1';
		selectExponentRes<="000"; --exponent1
		
		writeMantissaRes<='1';
		selectMantissaRes<="100"; --mantissaRes<=alu32bitOut
		
		comparator2Select<="011"; --mantissa1[]mantissa2
		
		writeSignRes<='1';
		overflow<=alu32bitCout;
		if(outSign1=outSign2) then
			--signs are the same. Just perform addition and write any sign
			alu32bitOp<="00";
			alu32bitSelect<="010"; --mantissa1 + mantissa2
			
			selectSignRes<="011"; --outSign1
		else
			alu32bitOp<="01";
			if(comparator2Greater='1') then
				--mantissa1>mantissa2
				selectSignRes<="011"; --outSign1
				alu32bitSelect<="010"; --mantissa1-mantissa2
			else
				--mantissa2>mantissa1
				selectSignRes<="100"; --outSign2
				alu32bitSelect<="011"; --mantissa2-mantissa1
			end if;
		end if;
		
	when fpMul_add=>
		writeSignRes<='1';
		selectSignRes<="010"; --sign1 xor sign2
		
		alu32bitOp<="00";
		alu32bitSelect<="101"; --exponent1 + exponent2
		writeExponentRes<='1';
		selectExponentRes<="100"; --exponentRes<=alu32bitOut
		
	when fpMul_sub127=>
		alu32bitOp<="01";
		alu32bitSelect<="110"; --exponentRes - 127
		writeExponentRes<='1';
		selectExponentRes<="100"; --exponentRes<=alu32bitOut
		
	when fpMul_mul=>
		writeMantissaRes<='1';
		selectMantissaRes<="111"; --mantissaRes<=mantissa1 * mantissa2 (63 downto 32);
	when align=>
		comparator1Select<="100"; --exponentRes [] x"00000000"
		
		if(comparator1Eq='1') then
			if(outSignRes='1') then
				--writeZeroNeg
			else
				--writeZeroPos
			end if;
		else
			if(overflow='1') then
				--shift right by 1, increment exponent and go to next state
				alu32bitOp<="10";
				alu32bitSelect<="100"; --exponentRes++
				
				writeExponentRes<='1';
				selectExponentRes<="100"; --exponentRes<=alu32bitOut
				
				writeMantissaRes<='1';
				selectMantissaRes<="101"; --mantissaRes>>1
			else
				if(outMantissaRes31='0') then
					--shift left by 1, decrement exponent and go to next state
					alu32bitOp<="11";
					alu32bitSelect<="100"; --exponentRes--
					
					writeExponentRes<='1';
					selectExponentRes<="100"; --exponentRes<=alu32bitOut
					
					writeMantissaRes<='1';
					selectMantissaRes<="110"; --mantissaRes<<1
				end if;
			end if;
		end if;
		
	when verify_exponent_overflow=>
		comparator2Select<="100"; --exponentRes [] 1FF
		
	when verify_exponent_underflow=> 
		comparator2Select<="101"; --100 [] exponentRes
		
	when writeNan=>
		writeSignRes<='1';
		selectSignRes<="000"; --x"00000000"
		
		writeExponentRes<='1';
		selectExponentRes<="011"; --x"FFFFFFFF"
		
		writeMantissaRes<='1';
		selectMantissaRes<="011"; --x"FFFFFFFF"
		
		nanFlag<='1';
		
	when writeInfinityPos=>
		writeSignRes<='1'; 
		selectSignRes<="000"; --x"00000000"
		
		writeExponentRes<='1';
		selectExponentRes<="011"; --x"FFFFFFFF"
		
		writeMantissaRes<='1';
		selectMantissaRes<="010"; --x"00000000"
		
		infinityFlag<='1';
	when writeInfinityNeg=>
		writeSignRes<='1'; 
		selectSignRes<="001"; --x"FFFFFFFF"
		
		writeExponentRes<='1';
		selectExponentRes<="011"; --x"FFFFFFFF"
		
		writeMantissaRes<='1';
		selectMantissaRes<="010"; --x"00000000"
		
		infinityFlag<='1';
	when writeInfinityXor=>
		writeSignRes<='1'; 
		selectSignRes<="010"; --sign1 xor sign2
		
		writeExponentRes<='1';
		selectExponentRes<="011"; --x"FFFFFFFF"
		
		writeMantissaRes<='1';
		selectMantissaRes<="010"; --x"00000000"
		
		infinityFlag<='1';
	when writeZeroPos=>
		writeSignRes<='1'; 
		selectSignRes<="000"; --x"00000000"
		
		writeExponentRes<='1';
		selectExponentRes<="010"; --x"00000000"
		
		writeMantissaRes<='1';
		selectMantissaRes<="010"; --x"00000000"
		
		zeroFlag<='1';
	when writeZeroNeg=>
		writeSignRes<='1'; 
		selectSignRes<="001"; --x"FFFFFFFF"
		
		writeExponentRes<='1';
		selectExponentRes<="010"; --x"00000000"
		
		writeMantissaRes<='1';
		selectMantissaRes<="010"; --x"00000000"
		
		zeroFlag<='1';
	when writeZeroXor=>
		writeSignRes<='1'; 
		selectSignRes<="010"; --sign1 xor sign2
		
		writeExponentRes<='1';
		selectExponentRes<="010"; --x"00000000"
		
		writeMantissaRes<='1';
		selectMantissaRes<="010"; --x"00000000"
		
		zeroFlag<='1';
	when writeNum1=>
		writeSignRes<='1';
		selectSignRes<="011"; --sign1
		
		writeExponentRes<='1';
		selectExponentRes<="000"; --exponent1
		
		writeMantissaRes<='1';
		selectMantissaRes<="000"; --mantissa1
	when writeNum2=>
		writeSignRes<='1';
		selectSignRes<="100"; --sign2
		
		writeExponentRes<='1';
		selectExponentRes<="001"; --exponent2
		
		writeMantissaRes<='1';
		selectMantissaRes<="001"; --mantissa2
	when others=>
end case;
end process;

end Behavioral;
