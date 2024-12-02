library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpAdderControlUnit is
	Port (
		clk:in std_logic;
		reset:in std_logic;
		
		comparatorEq:in std_logic;
		comparatorGreater:in std_logic;
		
		outSign1_0:in std_logic;
		outSign2_0:in std_logic;
		outMantissaRes24:in std_logic;
		outMantissaRes23:in std_logic;
		
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
		
		comparatorSelect:out std_logic_vector(2 downto 0);
		alu32bitSelect:out std_logic_vector(2 downto 0);
		alu32bitOp:out std_logic_vector(1 downto 0)
	);
end fpAdderControlUnit;

architecture Behavioral of fpAdderControlUnit is

type state_type is (idle_state,compare_state,add_state,align_state,verify_overflow_state,verify_underflow_state);
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
			state<=compare_state;
		else
			state<=idle_state;
		end if;
		
	when compare_state=>
		if(comparatorEq='1') then --exponent1=exponent2
			state<=add_state; --exponents are equal go to addition
		else
			state<=compare_state; --exponents are different, keep shifting
		end if;
	
	when add_state=>
		state<=align_state;
		
	when align_state=>
		if(comparatorEq='1') then
			state<=idle_state;
		else
			if(outMantissaRes23='0') then
				state<=align_state;
			else
				state<=verify_overflow_state;
			end if;
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
process(state,comparatorEq,comparatorGreater,outSign1_0,outSign2_0,outMantissaRes23)
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
		
	when compare_state=>
		dbState<="0001";
		
		comparatorSelect<="000"; --compare exponent1 and exponent2
		
		alu32bitOp<="10";
		
		--if exponents are different compute the difference and shift right
		if(comparatorEq /= '1') then
			if(comparatorGreater='1') then
				alu32bitSelect<="000";
				selectExponent2<="01";
				writeExponent2<='1';
				writeMantissa2<='1';
				selectMantissa2<="01";
			else
				alu32bitSelect<="001";
				selectExponent1<="01";
				writeExponent1<='1';
				writeMantissa1<='1';
				selectMantissa1<="01";
			end if;
		end if;
		
		
	when add_state=>
		dbState<="0010";
		
		writeSignRes<='1'; --we will find out the sing to write in this state
		
		writeExponentRes<='1';
		selectExponentRes<="00"; --write exponent to result since its aligned
		
		writeMantissaRes<='1';
		selectMantissaRes<="00"; --write aluRes to result mantissa
		
		comparatorSelect<="001"; --mantissa1 [] mantissa2
		
		if(outSign1_0 = outSign2_0) then
			--signs are equal, simply add the two mantissas and write sign1 to result
			selectSignRes<="00";
			
			alu32bitOp<="00";
			alu32bitSelect<="010";
		else
			alu32bitOp<="01"; --perform subtraction
			if(comparatorGreater='1') then
				--mantissa1>mantissa2 so write sign1 and mantissa1-mantissa2
				selectSignRes<="00";
				alu32bitSelect<="010";
			else
				--mantissa2>mantissa1 so write sign2 and mantissa2-mantissa1
				selectSignRes<="01";
				alu32bitSelect<="011";
			end if;
		end if;
		
	when align_state=>
		dbState<="0100";
		
		comparatorSelect<="010"; --mantissaRes [] x"00000000"
		
		if(comparatorEq='1') then
			--mantissa is 0 so make exponent 0
			writeExponentRes<='1';
			selectExponentRes<="01";
		else
			if(outMantissaRes24='1') then
				--shift right by 1 and increment exponent and shift right mantissa
				alu32bitOp<="10";
				alu32bitSelect<="100"; --increment exponent
				
				writeExponentRes<='1';
				selectExponentRes<="10"; --write exponent
				
				writeMantissaRes<='1';
				selectMantissaRes<="01"; --shift right
			else
				if(outMantissaRes23='0') then
				--shift left until we get a 1 on 23 and decrement exponent
				alu32bitOp<="11";
				alu32bitSelect<="100"; --decrement exponent
				
				writeExponentRes<='1';
				selectExponentRes<="10"; --write exponent
				
				writeMantissaRes<='1';
				selectMantissaRes<="10"; --shift left
				end if;
			end if;
		end if;
		
	when verify_overflow_state=>
	--check for exponent overflow
	dbState<="1000";
	comparatorSelect<="011";
	
	if(comparatorGreater='1') then
		--exponent overflow +- infinity
		writeExponentRes<='1';
		selectExponentRes<="11";
		
		--we have to use the alu since were out of inputs for the mantissa register
		writeMantissaRes<='1';
		selectMantissaRes<="00";
		
		alu32bitOp<="00"; --do 0+0
		alu32bitSelect<="101";
		
	end if;
	
	when verify_underflow_state=>
		dbState<="1001";
		comparatorSelect<="100";
		
		--exponent underflow
		--set everythin to 0
		--keep the sign though, since you can have +-0 maybe
		
		if(comparatorGreater = '0' and comparatorEq='0') then
			writeExponentRes<='1';
			selectExponentRes<="01";
			
			--we have to use the alu since were out of inputs for the mantissa register
			writeMantissaRes<='1';
			selectMantissaRes<="00";
			
			alu32bitOp<="00"; --do 0+0
			alu32bitSelect<="101";
		end if;
	when others=>
		
end case;
	
end process;

end Behavioral;
