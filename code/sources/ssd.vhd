----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2024 12:20:51 PM
-- Design Name: 
-- Module Name: ssd - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ssd is
    Port ( clk : in STD_LOGIC;
           num : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end ssd;

architecture Behavioral of ssd is

type digitType is array (3 downto 0) of std_logic_vector (3 downto 0);
signal count:std_logic_vector(16 downto 0);
signal inputDecoder:std_logic_vector(3 downto 0);

signal digits: digitType;

begin
digits(0)<=num(3 downto 0);
digits(1)<=num(7 downto 4);
digits(2)<=num(11 downto 8);
digits(3)<=num(15 downto 12);


--counter
process(clk)
begin

    if(clk'event and clk='1') then
        count<=count+1;
    end if;

end process;

--anode
process(count)
begin

    case count(16 downto 15) is
        when "00"=> an<="1110";
        when "01"=> an<="1101";
        when "10"=> an<="1011";
        when others=> an<="0111";
    end case;

end process;

--cathode
process(count,digits)
begin

    case count(16 downto 15) is
        when "00"=> inputDecoder<=digits(0);
        when "01"=> inputDecoder<=digits(1);
        when "10"=> inputDecoder<=digits(2);
        when others=> inputDecoder<=digits(3);
    end case;

end process;

--decoder
process(inputDecoder)
begin

    case inputDecoder is
        when "0000"=> cat<="1000000"; --0
        when "0001"=> cat<="1111001"; --1
        when "0010"=> cat<="0100100"; --2
        when "0011"=> cat<="0110000"; --3
        
        when "0100"=> cat<="0011001"; --4
        when "0101"=> cat<="0010010"; --5
        when "0110"=> cat<="0000010"; --6
        when "0111"=> cat<="1111000"; --7
        
        when "1000"=> cat<="0000000"; --8
        when "1001"=> cat<="0010000"; --9
        when "1010"=> cat<="0001000"; --A
        when "1011"=> cat<="0000011"; --B
        
        when "1100"=> cat<="1000110"; --C
        when "1101"=> cat<="0100001"; --D
        when "1110"=> cat<="0000110"; --E
        when others=> cat<="0001110"; --F
    end case;
    
end process;



end Behavioral;
