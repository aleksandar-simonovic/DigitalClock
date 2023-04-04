library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	port(
		clock : in std_logic;
		clock1Hz : in std_logic;
		reset : in std_logic;
		set	: in std_logic;
		increment : in std_logic;
		decrement : in std_logic;
		hour1 : out std_logic_vector(3 downto 0);
		hour0 : out std_logic_vector(3 downto 0);
		minute1 : out std_logic_vector(3 downto 0);
		minute0 : out std_logic_vector(3 downto 0);
		second1 : out std_logic_vector(3 downto 0);
		second0 : out std_logic_vector(3 downto 0);
		timer_buzzer: out std_logic
		
	);
end timer;

architecture beh_timer of timer is

	component count_down 
	port 
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
	END component;
	
	
	component binaryToBCD
	port
	(
	input:        in std_logic_vector(7 downto 0);   
   output_0:     out std_logic_vector(3 downto 0);  
	output_1:     out std_logic_vector(3 downto 0)
	);
	end component;
	
	
	COMPONENT edgedetector
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 strobe : IN STD_LOGIC;
		 p2 : OUT STD_LOGIC
	);
   END COMPONENT;

		
	
	
	type time_sm_type is
		(idle, countDown, setHour, setMinute, setSecond);
	signal state_reg, state_next : time_sm_type; 
	signal s_timer_buzzer: std_logic;
	signal setControl : std_logic;
	signal currentHour, currentMinute, currentSecond : std_logic_vector(7 downto 0);-- vrijeme na izlazu tajmera
	signal decoderHour, decoderMinute, decoderSecond : std_logic_vector(7 downto 0); -- signal na koji se prosljedjuje vrijeme na izlazu tajmera
	
	signal hourSetReg, minuteSetReg, secondSetReg : std_logic_vector(7 downto 0); --registri u koje upisujemo zeljeno vrijeme
	signal hourSetNext, minuteSetNext, secondSetNext : std_logic_vector(7 downto 0); -- registri nextState logike
begin
	
	counting : count_down
	port map(clock => clock,
				reset => reset,
				clockEnable => clock1Hz,
				set => setControl,
				hourIn => hourSetReg,
				minuteIn => minuteSetReg,
				secondIn => secondSetReg,
				hours => currentHour,
				minutes => currentMinute,
				seconds => currentSecond);
	
	
	
	decoderHourComponent : binaryToBCD
	port map(input => decoderHour,
				output_0 => hour0,
				output_1 => hour1);
	
	decoderMinuteComponent : binaryToBCD
	port map(input => decoderMinute,
				output_0 => minute0,
				output_1 => minute1);
				
	decoderSecondComponent : binaryToBCD
	port map(input => decoderSecond,
				output_0 => second0,
				output_1 => second1);
				
	ed : edgedetector
   PORT MAP(clk => clock,
		 reset => reset,
		 strobe => s_timer_buzzer,
		 p2 => timer_buzzer);
		 
	-- state register
	process(clock, reset)
	begin
	
		if(reset = '1') then
			state_reg <= idle;
			
		elsif rising_edge(clock) then
			state_reg <= state_next;
			
		end if;
	end process;
	
	-- hour,minute,second set register
	process(clock, reset)
	begin
	
		if(reset = '1') then
			hourSetReg <= "00000000";
			minuteSetReg <= "00000000";
			secondSetReg <= "00000000";
			
			
		elsif rising_edge(clock) then
			hourSetReg <= hourSetNext;
			minuteSetReg <= minuteSetNext;
			secondSetREg <= secondSetNext;
			
		end if;
	end process;
	
	--next-state logic
	process(state_reg, set)
	begin
		
		setControl <= '0';
		case state_reg is
			 
			 when idle =>
					if(set = '1') then
						 state_next <= setHour;
					else
						 state_next <= idle;
					end if;
		
					
			 when setHour =>
			 
					if(set = '1') then
						 state_next <= setMinute;
					else 
						 state_next <= setHour;
					end if;
			 when setMinute =>
			 
					if(set = '1') then 
						 state_next <= setSecond;
					else
						 state_next <= setMinute;
					end if;
			when setSecond =>
					if (set='1') then 
						state_next<=countDown;
						setControl <= '1';
					else 
						state_next<=setSecond;
						
					end if;	
			when countDown =>
					if (set='1') then 
						state_next <= setHour;
					else
						state_next <= countDown;
					end if;
		
		end case;
	end process;
	
	-- Output logic
	process(state_reg)
	begin
	
		case state_reg is
				 when idle  =>
				 --moze se poslati signal da se ugasi displej 
				 decoderHour <= currentHour;
						decoderMinute <= currentMinute;
						decoderSecond <= currentSecond; 
						s_timer_buzzer <= '0'; 
				 when countDown => 
				 
						decoderHour <= currentHour;
						decoderMinute <= currentMinute;
						decoderSecond <= currentSecond;
						if(currentHour="00000000") and (currentMinute="00000000") and (currentSecond="00000000") then 
							s_timer_buzzer <= '1';
						else 
							s_timer_buzzer <= '0' ;

						end if;
				 when setHour =>
				 
						decoderHour <= hourSetReg;
						decoderMinute <= minuteSetReg;
						decoderSecond <= secondSetReg;
						s_timer_buzzer <= '0'; 						
				 when setMinute =>
				 
						decoderHour <= hourSetReg;
						decoderMinute <= minuteSetReg;
						decoderSecond <= secondSetReg;
						s_timer_buzzer <= '0'; 	
							
				when setSecond => 
						decoderHour <= hourSetReg;
						decoderMinute <= minuteSetReg;
						decoderSecond <= secondSetReg;
						s_timer_buzzer <= '0'; 
				
					
			end case;
		
	end process;
	
	-- set logic
	process(state_reg,increment, decrement)
	begin
	
		hourSetNext <= hourSetReg;
		minuteSetNext <= minuteSetReg;
		secondSetNext <= secondSetReg;
		case state_reg is
				 when idle =>
				 
				 
				 when countDown => 
				 
						hourSetNext <= hourSetReg;
						minuteSetNext <= minuteSetReg;	
						secondSetNext <= secondSetReg;
				 when setHour =>
				 
						if increment='1' then
							if hourSetReg = "00010111" then
								hourSetNext <= "00000000";
				
							else
								hourSetNext <= std_logic_vector(unsigned(hourSetReg) + 1);
							end if;
						elsif decrement = '1' then
							if hourSetReg = "00000000" then
								hourSetNext <= "00010111";
							else 
								hourSetNext <= std_logic_vector(unsigned(hourSetReg) - 1);
							end if;
						end if;
				 when setMinute =>
				 
						if increment='1' then
							if minuteSetReg = "00111011" then
								minuteSetNext <= "00000000";
							else
								minuteSetNext <= std_logic_vector(unsigned(minuteSetReg) + 1);
							end if;
						elsif decrement = '1' then
							if minuteSetReg = "00000000" then
								minuteSetNext <= "00111011";
							else 
								minuteSetNext <= std_logic_vector(unsigned(minuteSetReg) - 1);
							end if;
						end if;
						
			   when setSecond =>
				 
						if increment='1' then
							if secondSetReg = "00111011" then
								secondSetNext <= "00000000";
							else
								secondSetNext <= std_logic_vector(unsigned(secondSetReg) + 1);
							end if;
						elsif decrement = '1' then
							if secondSetReg = "00000000" then
								secondSetNext <= "00111011";
							else 
								secondSetNext <= std_logic_vector(unsigned(secondSetReg) - 1);
							end if;
						end if;
			end case;
			
			
	end process;
	
	
end architecture;
