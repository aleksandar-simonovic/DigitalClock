library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity outputFSM is
port (
    clock 			 		: in std_logic;
	 reset			 		: in std_logic;
	 mode				 		: in std_logic;
	 set 				 		: in std_logic;
	 clock1Hz		 		: in std_logic;
	 inactiveFor10s 		: in std_logic;
	 disableMode 			: in std_logic;
	 
	 alarm_hour1 			: in std_logic_vector(3 downto 0);
	 alarm_hour0 			: in std_logic_vector(3 downto 0);
	 alarm_minute1 		: in std_logic_vector(3 downto 0);
	 alarm_minute0 		: in std_logic_vector(3 downto 0);
	 alarm_onoff 			: in std_logic_vector(3 downto 0);
	 
	 stopwatch_hunderth1 : in std_logic_vector(3 downto 0);
	 stopwatch_hunderth0 : in std_logic_vector(3 downto 0);
	 stopwatch_second1 	: in std_logic_vector(3 downto 0);
	 stopwatch_second0 	: in std_logic_vector(3 downto 0);
	 stopwatch_minute1 	: in std_logic_vector(3 downto 0);
	 stopwatch_minute0 	: in std_logic_vector(3 downto 0);
	 
	 timer_hour1 			: in std_logic_vector(3 downto 0);
	 timer_hour0 			: in std_logic_vector(3 downto 0);
	 timer_minute1 		: in std_logic_vector(3 downto 0);
	 timer_minute0 		: in std_logic_vector(3 downto 0);
	 timer_second1 		: in std_logic_vector(3 downto 0);
	 timer_second0 		: in std_logic_vector(3 downto 0);
	 
	 currentTime_hour1 	: in std_logic_vector(3 downto 0);
	 currentTime_hour0 	: in std_logic_vector(3 downto 0);
	 currentTime_minute1 : in std_logic_vector(3 downto 0);
	 currentTime_minute0 : in std_logic_vector(3 downto 0);
	 currentTime_second1 : in std_logic_vector(3 downto 0);
	 currentTime_second0 : in std_logic_vector(3 downto 0);
	 
	 
	 toDisplay0 			: out std_logic_vector(3 downto 0); --najlaksi
	 toDisplay1 			: out std_logic_vector(3 downto 0);
	 toDisplay2 			: out std_logic_vector(3 downto 0);
	 toDisplay3 			: out std_logic_vector(3 downto 0);
	 toDisplay4 			: out std_logic_vector(3 downto 0);
	 toDisplay5 			: out std_logic_vector(3 downto 0);  --najtezi
	 
	 stopWatchInactive   : out std_logic
	 
	);
	end outputFSM;
	
	architecture beh of outputFSM is
	
	   type state_type is (currentTime, setHourCurrentTime, setMinuteCurrentTime, 
								  alarm, setHourAlarm, setMinuteAlarm,
								  timer, setHourTimer, setMinuteTimer, setSecondTimer,
								  stopwatch);
								  
		signal state_reg, state_next: state_type;
		
		signal s_stopwatchInactive : std_logic;
		
		begin
			s_stopwatchInactive <= '1' when (stopwatch_hunderth1 = "0000") and (stopwatch_hunderth0 = "0000") and
													(stopwatch_second1 = "0000") and (stopwatch_second0 = "0000") and
													(stopwatch_minute1 = "0000") and (stopwatch_minute0 = "0000") else
										'0';
			
			--STATE REGISTER
		   process(clock,reset)
			begin
			    if (reset='1') then
				    state_reg <= currentTime;
				 elsif (rising_edge(clock)) then
				     state_reg<= state_next;
				end if;
			end process;
			
			--NEXT STATE LOGIC
			process(state_reg, mode, set)
			begin
				case state_reg is
				
				   when currentTime => 
						if set = '1' then
							state_next <= setHourCurrentTime;
						elsif mode = '1' and disableMode = '0' then
							state_next <= alarm;
						else
							state_next <= currentTime;
						end if;
						
				   when setHourCurrentTime => 
						if set = '1' then
							state_next <= setMinuteCurrentTime;
						else
							state_next <= setHourCurrentTime;
						end if;
						
					when setMinuteCurrentTime =>
						if set = '1' then
							state_next <= currentTime;
						else
							state_next <= setMinuteCurrentTime;
						end if;
						
					when alarm =>
						if set = '1' then
							state_next <= setHourAlarm;
						elsif inactiveFor10s = '1' then
							state_next <= currentTime;
						elsif mode = '1' and disableMode = '0' then
							state_next <= timer;
						else
							state_next <= alarm;
						end if;
					
					when setHourAlarm =>
						if set = '1' then
							state_next <= setMinuteAlarm;
						else
							state_next <= setHourAlarm;
						end if;
					
					when setMinuteAlarm => 
						if set = '1' then
							state_next <= alarm;
						else
							state_next <= setMinuteAlarm;
						end if;
					
					when timer =>
						if set = '1' then
							state_next <= setHourTimer;
						elsif inactiveFor10s = '1' then
							state_next <= currentTime;
						elsif mode = '1' and disableMode = '0' then
							state_next <= stopwatch;
						else
							state_next <= timer;
						end if;
					
					when setHourTimer =>
						if set = '1' then
							state_next <= setMinuteTimer;
						else
							state_next <= setHourTimer;
						end if;
					
					when setMinuteTimer => 
						if set = '1' then
							state_next <= setSecondTimer;
						else
							state_next <= setMinuteTimer;
						end if;
					
					when setSecondTimer => 
						if set = '1' then
							state_next <= timer;
						else
							state_next <= setSecondTimer;
						end if;
					
					when stopwatch =>
						if inactiveFor10s = '1' and s_stopwatchInactive = '1' then
							state_next <= currentTime;
						elsif mode = '1' and disableMode = '0' then
							state_next <= currentTime;
						else 
							state_next <= stopwatch;
						end if;
				end case;
			end process;	
			
			--OUTPUT LOGIC
			process(state_reg)
			begin
				case state_reg is
				
					when currentTime => 
						toDisplay0 <= currentTime_second0;
						toDisplay1 <= currentTime_second1;
						toDisplay2 <= currentTime_minute0;
						toDisplay3 <= currentTime_minute1;
						toDisplay4 <= currentTime_hour0;
						toDisplay5 <= currentTime_hour1;
						
				   when setHourCurrentTime => 
						toDisplay0 <= currentTime_second0;
						toDisplay1 <= currentTime_second1;
						toDisplay2 <= currentTime_minute0;
						toDisplay3 <= currentTime_minute1;
						if (clock1Hz = '1') then 
							toDisplay4 <= currentTime_hour0;
							toDisplay5 <= currentTime_hour1;
						else 
							toDisplay4 <= "1111";
							toDisplay5 <= "1111";
						end if;
						
					when setMinuteCurrentTime =>
						toDisplay0 <= currentTime_second0;
						toDisplay1 <= currentTime_second1;
						
						if (clock1Hz = '1') then
							toDisplay2 <= currentTime_minute0;
							toDisplay3 <= currentTime_minute1;
						else
							toDisplay2 <= "1111";
							toDisplay3 <= "1111";
						end if;
						toDisplay4 <= currentTime_hour0;
						toDisplay5 <= currentTime_hour1;
						
					when alarm =>
						toDisplay0 <= alarm_onoff;
						toDisplay1 <= "1111";
						toDisplay2 <= alarm_minute0;
						toDisplay3 <= alarm_minute1;
						toDisplay4 <= alarm_hour0;
						toDisplay5 <= alarm_hour1;
					
					when setHourAlarm =>
						toDisplay0 <= alarm_onoff;
						toDisplay1 <= "1111";
						toDisplay2 <= alarm_minute0;
						toDisplay3 <= alarm_minute1;
						if (clock1Hz = '1') then 
							toDisplay4 <= alarm_hour0;
							toDisplay5 <= alarm_hour1;
						else 
							toDisplay4 <= "1111";
							toDisplay5 <= "1111";
						end if;
					
					when setMinuteAlarm => 
						toDisplay0 <= alarm_onoff;
						toDisplay1 <= "1111";
						if (clock1Hz = '1') then
							toDisplay2 <= alarm_minute0;
							toDisplay3 <= alarm_minute1;
						else
							toDisplay2 <= "1111";
							toDisplay3 <= "1111";
						end if;
						toDisplay4 <= alarm_hour0;
						toDisplay5 <= alarm_hour1;
					
					when timer =>
						toDisplay0 <= timer_second0;
						toDisplay1 <= timer_second1;
						toDisplay2 <= timer_minute0;
						toDisplay3 <= timer_minute1;
						toDisplay4 <= timer_hour0;
						toDisplay5 <= timer_hour1;
						
					when setHourTimer =>
						toDisplay0 <= timer_second0;
						toDisplay1 <= timer_second1;
						toDisplay2 <= timer_minute0;
						toDisplay3 <= timer_minute1;
						if (clock1Hz = '1') then 
							toDisplay4 <= timer_hour0;
							toDisplay5 <= timer_hour1;
						else 
							toDisplay4 <= "1111";
							toDisplay5 <= "1111";
						end if;
					
					when setMinuteTimer => 
						toDisplay0 <= timer_second0;
						toDisplay1 <= timer_second1;
						if (clock1Hz = '1') then
							toDisplay2 <= timer_minute0;
							toDisplay3 <= timer_minute1;
						else
							toDisplay2 <= "1111";
							toDisplay3 <= "1111";
						end if;
						toDisplay4 <= timer_hour0;
						toDisplay5 <= timer_hour1;
					
					when setSecondTimer => 
						if (clock1Hz = '1') then
							toDisplay0 <= timer_second0;
							toDisplay1 <= timer_second1;
						else
							toDisplay0 <= "1111";
							toDisplay1 <= "1111";
						end if;
						toDisplay2 <= timer_minute0;
						toDisplay3 <= timer_minute1;
						toDisplay4 <= timer_hour0;
						toDisplay5 <= timer_hour1;
					
					when stopwatch =>
						toDisplay0 <= stopwatch_hunderth0;
						toDisplay1 <= stopwatch_hunderth1;
						toDisplay2 <= stopwatch_second0;
						toDisplay3 <= stopwatch_second1;
						toDisplay4 <= stopwatch_minute0;
						toDisplay5 <= stopwatch_minute1;
					
				end case;
			end process;
			
			stopWatchInactive <= s_stopWatchInactive;
		end architecture;