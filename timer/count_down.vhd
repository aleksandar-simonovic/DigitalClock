LIBRARY ieee;
USE ieee.std_logic_1164.all; 

--LIBRARY work;

ENTITY count_down IS 
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
END count_down;

ARCHITECTURE beh_count_down OF count_down IS 

COMPONENT edgedetector
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 strobe : IN STD_LOGIC;
		 p2 : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT counter24_down 
	PORT(reset : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 dataIn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dataOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT counter60_down
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
signal hour_wire : std_logic_vector(7 downto 0 );
SIGNAL	WIRESECOND :  STD_LOGIC;
SIGNAL	WIREMINUTE :  STD_LOGIC;
SIGNAL	WIREENABLE :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL   reset_wire_out : std_logic; --kad je stanje svih nula na izlazu, ukjuci reset, odnosno setuj sve na 0
SIGNAL  reset_wire_in : std_logic; 
SIGNAL enable_wire :std_logic;

BEGIN 


-- logika za brojanje unazad
WIRESECOND <= NOT(seconds_wire(0) OR seconds_wire(1) OR seconds_wire(2) OR seconds_wire(3) OR seconds_wire(4) OR seconds_wire(5) OR seconds_wire(6) OR seconds_wire(7)) AND SYNTHESIZED_WIRE_5 and enable_wire;
WIREMINUTE <= NOT(minutes_wire(0) OR minutes_wire(1) OR minutes_wire(2) OR minutes_wire(3) OR minutes_wire(4) OR minutes_wire(5) OR minutes_wire(6) OR minutes_wire(7)) AND WIRESECOND and enable_wire;
WIREENABLE <= SYNTHESIZED_WIRE_5  AND enable_wire ;
enable_wire<= seconds_wire(0) OR seconds_wire(1) OR seconds_wire(2) OR seconds_wire(3) OR seconds_wire(4) OR seconds_wire(5) OR seconds_wire(6) OR seconds_wire(7) OR minutes_wire(0) OR minutes_wire(1) OR minutes_wire(2) OR minutes_wire(3) OR minutes_wire(4) OR minutes_wire(5) OR minutes_wire(6) OR minutes_wire(7) OR hour_wire(0) OR hour_wire(1) OR hour_wire(2) OR hour_wire(3) OR hour_wire(4)  or hour_wire(5) or hour_wire(6) or hour_wire(7); 
--zadrzavanje u stanju



b2v_ed : edgedetector
PORT MAP(clk => clock,
		 reset => reset,
		 strobe => clockEnable,
		 p2 => SYNTHESIZED_WIRE_5);


b2v_h24 : counter24_down
PORT MAP(reset => reset,
		 set => set,
		 clock => clock,
		 enable => WIREMINUTE,
		 dataIn => hourIn,
		 dataOut => hour_wire);




b2v_m60 : counter60_down
PORT MAP(reset => reset,
		 set => set,
		 clock => clock,
		 enable => WIRESECOND,
		 dataIn => minuteIn,
		 dataOut => minutes_wire);


b2v_s60 : counter60_down
PORT MAP(reset => reset,
		 set => set,
		 clock => clock,
		 enable => WIREENABLE,
		 dataIn => secondIn,
		 dataOut => seconds_wire);
		 
minutes <= minutes_wire;
seconds <= seconds_wire;
hours <=hour_wire;

END beh_count_down;