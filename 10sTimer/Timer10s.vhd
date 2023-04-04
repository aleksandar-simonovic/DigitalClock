LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Timer10s IS
    PORT(
        reset      : 			IN STD_LOGIC := '0';  --reset
        clock      : 	      IN STD_LOGIC;    		 --klok 50MHz
        clockEnable:  	      IN STD_LOGIC;	 		 --1Hz
        TASTER0    : 			IN STD_LOGIC := '0';  --taster0
        TASTER1    : 			IN STD_LOGIC := '0';  --taster1
        TASTER2    : 			IN STD_LOGIC := '0';  --taster2
        TASTER3    : 			IN STD_LOGIC := '0';  --taster3
	inactiveFor10s  :    	   OUT STD_LOGIC         --izlaz tajmera IDLE='0', ako poslije 10s se ne pritisne nijedan taster prelazi u '1'
    );
END Timer10s;

ARCHITECTURE Timer10s_arch OF Timer10s IS

COMPONENT edgeDetector
	PORT(
		 clk     : IN STD_LOGIC;
		 reset   : IN STD_LOGIC;
		 strobe  : IN STD_LOGIC;
		 p2      : OUT STD_LOGIC
	);
	END COMPONENT;

	COMPONENT counter10 
	PORT(
		 reset   : IN STD_LOGIC;
		 set     : IN STD_LOGIC;
		 clock   : IN STD_LOGIC;
		 enable  : IN STD_LOGIC;
		 dataIn  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dataOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
signal s_enable_wire,s_clear : std_logic; 
signal s_out : std_logic_vector(7 downto 0);
signal s_clockEnable : std_logic;
	
BEGIN

s_clockEnable <= clockEnable;
s_clear <=  TASTER0 or TASTER1 or TASTER2 or TASTER3;


Detector     : edgeDetector port map(clk=>clock,reset=>reset,strobe=>s_clockEnable,p2=>s_enable_wire);
Counter10s 	 : counter10 port map(reset=>reset,set=>s_clear,clock=>clock,enable=>s_enable_wire,dataIn=>"00000000",dataOut=>s_out);

inactiveFor10s<= s_out(1) and s_out(3);
END Timer10s_arch;