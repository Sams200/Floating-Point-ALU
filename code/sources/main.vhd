library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity main is
    Port ( clk : in STD_LOGIC;
           XbtnU : in STD_LOGIC;
           XbtnD : in STD_LOGIC;
           XbtnL: in std_logic;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           led:out std_logic);
end main;

architecture Behavioral of main is

------------------------------------
component debouncer is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           dbOut : out STD_LOGIC);
end component;

component ssd is
    Port ( clk : in STD_LOGIC;
           num : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component dataMemory is
    Port ( clk : in STD_LOGIC;
           reset:in STD_LOGIC;
           dataOut1 : out STD_LOGIC_VECTOR (31 downto 0);
           dataOut2 : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component aluFloat is
    Port ( clk : in STD_LOGIC;
           num1 : in STD_LOGIC_VECTOR (31 downto 0);
           num2 : in STD_LOGIC_VECTOR (31 downto 0);
           op : in STD_LOGIC;
           start:in std_logic;
           res : out STD_LOGIC_VECTOR (31 downto 0);
           working:out std_logic);
end component;
----------------------

----signals------------------------
signal btnU:std_logic;
signal btnD:std_logic;
signal btnL:std_logic;

signal result:std_logic_vector(31 downto 0);
signal num1:std_logic_vector(31 downto 0);
signal num2:std_logic_vector(31 downto 0);
signal display:std_logic_vector(15 downto 0);
-----------------------------------

begin

debouncerUL:debouncer port map(clk=>clk, btn=>XbtnU, dbOut=>btnU);
debouncerDL:debouncer port map(clk=>clk, btn=>XbtnD, dbOut=>btnD);
debouncerLL:debouncer port map(clk=>clk, btn=>XbtnL, dbOut=>btnL);
ssdL:ssd port map(clk=>clk, num=>display, an=>an, cat=>cat);

rom:dataMemory port map(clk=>btnU, reset=>sw(0), dataOut1=>num1, dataOut2=>num2);
alu:aluFloat port map(clk=>btnD, num1=>num1, num2=>num2, op=>sw(0), res=>result, working=>led,start=>btnL);

process(sw)
begin

    case sw(15 downto 13) is
        when "001"=> display<=num1(15 downto 0);
        when "011"=> display<=num1(31 downto 16);
        when "100"=> display<=num2(15 downto 0);
        when "101"=> display<=num2(31 downto 16);
        when "111"=> display<=result(31 downto 16);
        when others=> display<=result(15 downto 0);
    end case;
end process;

end Behavioral;
