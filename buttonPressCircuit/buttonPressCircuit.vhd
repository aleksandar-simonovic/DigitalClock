library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buttonPressCircuit is
	port(
		clock	  		: in std_logic;
	
		alarmSwitch : in std_logic;
		taster0 		: in std_logic;
		taster1 		: in std_logic;
		taster2 		: in std_logic;
		taster3 		: in std_logic;
		
		alarmSwitchOutput : out std_logic;
		taster0Output 		: out std_logic;
		taster1Output	   : out std_logic;
		taster2Output 		: out std_logic;
		taster3Output 		: out std_logic
	);
end entity;

architecture beh of buttonPressCircuit is
	signal taster0reg1 : std_logic;
	signal taster0reg2 : std_logic;
	
	signal taster1reg1 : std_logic;
	signal taster1reg2 : std_logic;
	
	signal taster2reg1 : std_logic;
	signal taster2reg2 : std_logic;
	
	signal taster3reg1 : std_logic;
	signal taster3reg2 : std_logic;
	
	signal switchreg1 : std_logic;
	signal switchreg2 : std_logic;
	
begin
	process(clock)
	begin
		if rising_edge(clock) then
			taster0reg1 <= taster0;
			taster0reg2 <= taster0reg1;
			
			taster1reg1 <= taster1;
			taster1reg2 <= taster1reg1;
			
			taster2reg1 <= taster2;
			taster2reg2 <= taster2reg1;
			
			taster3reg1 <= taster3;
			taster3reg2 <= taster3reg1;
			
			switchreg1 <= alarmSwitch;
			switchreg2 <= switchreg1;
		end if;
	end process;
	
	taster0Output <= taster0reg1 and not(taster0reg2);
	taster1Output <= taster1reg1 and not(taster1reg2);
	taster2Output <= taster2reg1 and not(taster2reg2);
	taster3Output <= taster3reg1 and not(taster3reg2);
	alarmSwitchOutput <= switchreg2;
		
end architecture;
