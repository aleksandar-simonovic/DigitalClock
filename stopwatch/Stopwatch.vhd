library ieee;
use ieee.std_logic_1164.all;

ENTITY Stopwatch IS 
PORT(

	clock : in std_logic; 	
	clock100Hz : in std_logic; 	
	start_stop : in std_logic;
	clear : in std_logic;
	reset : in std_logic;

	hundert1 : out std_logic_vector(3 downto 0);
	hundert0 : out std_logic_vector(3 downto 0);
	minute1 : out std_logic_vector(3 downto 0);
	minute0 : out std_logic_vector(3 downto 0);
	second1 : out std_logic_vector(3 downto 0);
	second0 : out std_logic_vector(3 downto 0)
		
);
END ENTITY Stopwatch;

ARCHITECTURE Stopwatch_arch OF Stopwatch IS

	
	COMPONENT edgedetector
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 strobe : IN STD_LOGIC;
		 p2 : OUT STD_LOGIC
	);
	END COMPONENT;

	COMPONENT counter100
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
	
	component binaryToBCD
	port
	(
	input:        in std_logic_vector(7 downto 0);   
   output_0:     out std_logic_vector(3 downto 0);  
	output_1:     out std_logic_vector(3 downto 0)
	);
	end component;

	
	SIGNAL	enable_wire :  STD_LOGIC;
	signal   s_start_stop : std_logic := '0';
	
	SIGNAL	enable_hunderts_wire :  STD_LOGIC;
	SIGNAL	enable_seconds_wire :  STD_LOGIC;
	SIGNAL	enable_minutes_wire :  STD_LOGIC;
	
	signal hunderts_wire : std_logic_vector(7 downto 0);
	signal seconds_wire : std_logic_vector(7 downto 0);
	signal minutes_wire : std_logic_vector(7 downto 0);
	
	
BEGIN

	enable_hunderts_wire <= enable_wire and s_start_stop;
	enable_seconds_wire  <= enable_hunderts_wire and hunderts_wire(6) and hunderts_wire(5) and hunderts_wire(1) and hunderts_wire(0);
	enable_minutes_wire  <= enable_seconds_wire and seconds_wire(5) and seconds_wire(4) and seconds_wire(3) and seconds_wire(1) and seconds_wire(0);
	
	process(clock, reset)
	begin
		
		if (reset = '1') then
		
			s_start_stop <= '0';			
		elsif(rising_edge(clock)) then
		
			if (start_stop = '1') then			
				s_start_stop <= not s_start_stop;
			end if;
		end if;
	end process;
	

	b2v_ed : edgedetector
	PORT MAP(clk => clock,
		 reset => reset,
		 strobe => clock100Hz,
		 p2 => enable_wire);		 

	b2v_h100 : counter100
	PORT MAP(reset => reset,
			 set => clear,
			 clock => clock,
			 enable => enable_hunderts_wire,
			 dataIn => "00000000",
			 dataOut => hunderts_wire);

	b2v_s60 : counter60
	PORT MAP(reset => reset,
			 set => clear,
			 clock => clock,
			 enable => enable_seconds_wire,
			 dataIn => "00000000",
			 dataOut => seconds_wire);

	b2v_m60 : counter60
	PORT MAP(reset => reset,
			 set => clear,
			 clock => clock,
			 enable => enable_minutes_wire,
			 dataIn => "00000000",
			 dataOut => minutes_wire);
			 
	
	decoderHundertsComponent : binaryToBCD
	port map(input => hunderts_wire,
				output_0 => hundert0,
				output_1 => hundert1);
	
	decoderMinuteComponent : binaryToBCD
	port map(input => minutes_wire,
				output_0 => minute0,
				output_1 => minute1);
				
	decoderSecondComponent : binaryToBCD
	port map(input => seconds_wire,
				output_0 => second0,
				output_1 => second1);
	
	
END ARCHITECTURE Stopwatch_arch;


