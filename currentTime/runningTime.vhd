LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY runningTime IS 
	PORT
	(
		clock :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		clockEnable :  IN  STD_LOGIC;
		set :  IN  STD_LOGIC;
		hourIn :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		minuteIn :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		secondIn :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		hours :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		minutes :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		seconds :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END runningTime;

ARCHITECTURE bdf_type OF runningTime IS 

COMPONENT edgedetector
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 strobe : IN STD_LOGIC;
		 p2 : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT counter24
	PORT(reset : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 dataIn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dataOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT counter60
	PORT(reset : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 dataIn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dataOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

signal seconds_wire : std_logic_vector(7 downto 0);
signal minutes_wire : std_logic_vector(7 downto 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;


BEGIN 

SYNTHESIZED_WIRE_0 <= SYNTHESIZED_WIRE_6 and minutes_wire(0) and minutes_wire(1) and minutes_wire(3) and minutes_wire(4) and minutes_wire(5);
SYNTHESIZED_WIRE_6 <= seconds_wire(0) and seconds_wire(1) and seconds_wire(3) and seconds_wire(4) and seconds_wire(5) and SYNTHESIZED_WIRE_5; 
b2v_ed : edgedetector
PORT MAP(clk => clock,
		 reset => reset,
		 strobe => clockEnable,
		 p2 => SYNTHESIZED_WIRE_5);


b2v_h24 : counter24
PORT MAP(reset => reset,
		 set => set,
		 clock => clock,
		 enable => SYNTHESIZED_WIRE_0,
		 dataIn => hourIn,
		 dataOut => hours);




b2v_m60 : counter60
PORT MAP(reset => reset,
		 set => set,
		 clock => clock,
		 enable => SYNTHESIZED_WIRE_6,
		 dataIn => minuteIn,
		 dataOut => minutes_wire);


b2v_s60 : counter60
PORT MAP(reset => reset,
		 set => set,
		 clock => clock,
		 enable => SYNTHESIZED_WIRE_5,
		 dataIn => secondIn,
		 dataOut => seconds_wire);
		 
minutes <= minutes_wire;
seconds <= seconds_wire;


END bdf_type;