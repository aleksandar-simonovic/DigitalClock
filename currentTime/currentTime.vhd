library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity currentTime is
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
		second0 : out std_logic_vector(3 downto 0)
		
	);
end currentTime;

architecture beh of currentTime is

	component runningTime 
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

		
	
	
	type time_sm_type is
		(idle, setHour, setMinute);
	signal state_reg, state_next : time_sm_type; 
	
	signal setControl : std_logic;
	signal currentHour, currentMinute, currentSecond : std_logic_vector(7 downto 0);
	signal decoderHour, decoderMinute, decoderSecond : std_logic_vector(7 downto 0);
	
	signal hourSetReg, minuteSetReg : std_logic_vector(7 downto 0);
	signal hourSetNext, minuteSetNext : std_logic_vector(7 downto 0);
begin
	
	timeCounter : runningTime
	port map(clock => clock,
				reset => reset,
				clockEnable => clock1Hz,
				set => setControl,
				hourIn => hourSetReg,
				minuteIn => minuteSetReg,
				secondIn => "00000000",
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
	-- state register
	process(clock, reset)
	begin
	
		if(reset = '1') then
			state_reg <= idle;
			
		elsif rising_edge(clock) then
			state_reg <= state_next;
			
		end if;
	end process;
	
	-- hour and minute set register
	process(clock, reset)
	begin
	
		if(reset = '1') then
			hourSetReg <= "00000000";
			MinuteSetReg <= "00000000";
			
		elsif rising_edge(clock) then
			hourSetReg <= hourSetNext;
			minuteSetReg <= minuteSetNext;
			
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
						 state_next <= idle;
						 setControl <= '1';
					else
						 state_next <= setMinute;
					end if;			 
		end case;
	end process;
	
	-- Output logic
	process(state_reg)
	begin
		case state_reg is
				 when idle => 
				 
						decoderHour <= currentHour;
						decoderMinute <= currentMinute;
						decoderSecond <= currentSecond;
				 when setHour =>
				 
						decoderHour <= hourSetReg;
						decoderMinute <= minuteSetReg;
						decoderSecond <= "00000000";						
				 when setMinute =>
				 
						decoderHour <= hourSetReg;
						decoderMinute <= minuteSetReg;
						decoderSecond <= "00000000";								 
			end case;
		
	end process;
	
	-- set logic
	process(state_reg,increment, decrement)
	begin
	
		hourSetNext <= hourSetReg;
		minuteSetNext <= minuteSetReg;
		case state_reg is
				 
				 
				 when idle => 
				 
						hourSetNext <= hourSetReg;
						minuteSetNext <= minuteSetReg;						
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
			end case;
	end process;
	
	
end architecture;
