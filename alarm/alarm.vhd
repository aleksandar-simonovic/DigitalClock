library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm is
	port(
		clock 					: in std_logic;
		reset 					: in std_logic;
		set						: in std_logic;
		increment 				: in std_logic;
		decrement 				: in std_logic;
		alarm_enable  			: in std_logic;
		currentTime_hour1    : in std_logic_vector(3 downto 0);
		currentTime_hour0    : in std_logic_vector(3 downto 0);
		currentTime_minute1	: in std_logic_vector(3 downto 0);
		currentTime_minute0  : in std_logic_vector(3 downto 0);
		alarm_hour1 			: out std_logic_vector(3 downto 0);
		alarm_hour0 			: out std_logic_vector(3 downto 0);
		alarm_minute1 			: out std_logic_vector(3 downto 0);
		alarm_minute0 			: out std_logic_vector(3 downto 0);
		alarm_onoff 			: out std_logic_vector(3 downto 0);
		alarm_buzzer 			: out std_logic
	);
end entity;

architecture beh of alarm is
	type state_type is (idle, setHour, setMinute);
	signal state_reg, state_next : state_type;
	
	signal s_alarm_buzzer : std_logic;
	signal hourSetReg, minuteSetReg : std_logic_vector(7 downto 0);
	signal hourSetNext, minuteSetNext : std_logic_vector(7 downto 0);
	
	signal hour1BCD, hour0BCD, minute1BCD, minute0BCD : std_logic_vector(3 downto 0);
	
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
	
begin

	ed : edgedetector
   PORT MAP(clk => clock,
		 reset => reset,
		 strobe => s_alarm_buzzer,
		 p2 => alarm_buzzer);
		 
	decoderHourComponent : binaryToBCD
	port map(input => hourSetReg,
				output_0 => hour0BCD,
				output_1 => hour1BCD);
	
	decoderMinuteComponent : binaryToBCD
	port map(input => minuteSetReg,
				output_0 => minute0BCD,
				output_1 => minute1BCD);

	--state register
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
			hourSetReg   <= "00000000";
			MinuteSetReg <= "00000000";
			
		elsif rising_edge(clock) then
			hourSetReg <= hourSetNext;
			minuteSetReg <= minuteSetNext;
			
		end if;
	end process;
	
	--next state logic
	process(state_reg, set)
	begin
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
					else
						 state_next <= setMinute;
					end if;			 
		end case;
	end process;
	
	-- set logic 
	process(state_reg, increment, decrement)
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
	
	process(alarm_enable, currentTime_hour1, currentTime_hour0, currentTime_minute1, currentTime_minute0, 
			  hour1BCD, hour0BCD, minute1BCD, minute0BCD, state_reg)
	begin
		if((alarm_enable = '1') and (currentTime_hour1 = hour1BCD) and (currentTime_hour0 = hour0BCD) and (currentTime_minute1 = minute1BCD)
			and (currentTime_minute0 = minute0BCD) and (state_reg = idle)) then
			s_alarm_buzzer <= '1';
		else
			s_alarm_buzzer <= '0';
		end if;
	end process;
			  
	alarm_hour1 <= hour1BCD;
	alarm_hour0 <= hour0BCD;
	alarm_minute1 <= minute1BCD;
	alarm_minute0 <= minute0BCD;
	
	alarm_onoff <= "1010" when alarm_enable = '1' else
						"1111";
	
end architecture;
