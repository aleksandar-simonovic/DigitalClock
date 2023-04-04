library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InputFSM is
port (
	 
-- Input ports
		
		TASTER1	     	  : in  std_logic;
		TASTER2	     	  : in  std_logic;
		TASTER3	     	  : in  std_logic;
		mode 				  : in  std_logic;
		set 				  : in  std_logic;
		reset    	     : in  std_logic;
		inactiveFor10s	  : in  std_logic;
		disableMode  	  : in  std_logic;
		clock 		     : in  std_logic;
		stopwatchInactive: in  std_logic;
		
		-- Output ports
		currentTime_set 		: out std_logic;
		currentTime_increment: out std_logic;
		currentTime_decrement: out std_logic;
		alarm_set 				: out std_logic;
		alarm_increment 		: out std_logic;
		alarm_decrement 		: out std_logic;
		stopwatch_start		: out std_logic; --start/stop
		stopwatch_clear		: out std_logic;
		timer_set 		 		: out std_logic;
		timer_increment 		: out std_logic;
		timer_decrement 		: out std_logic
				
	 
	);
	end InputFSM;
	
	architecture beh of InputFSM is
	
	   type state_type is (currentTime, setHourCurrentTime, setMinuteCurrentTime, 
								  alarm, setHourAlarm, setMinuteAlarm,
								  timer, setHourTimer, setMinuteTimer, setSecondTimer,
								  stopwatch);
		signal state_reg, state_next: state_type;

		
		begin

			
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
						if inactiveFor10s = '1' and stopwatchInactive = '1' then
							state_next <= currentTime;
						elsif mode = '1' and disableMode = '0' then
							state_next <= currentTime;
						else 
							state_next <= stopwatch;
						end if;
					end case;
			end process;	
			
			
			--otput logic
	process(state_reg)
		begin
		
		currentTime_set 		 <= '0';
		currentTime_increment <= '0';
		currentTime_decrement <= '0';
		alarm_set 		 		 <= '0';
		alarm_increment 		 <= '0';
		alarm_decrement		 <= '0';
		stopwatch_start 		 <= '0';
		stopwatch_clear		 <= '0';
	   timer_set 		  		 <= '0';
		timer_increment 		 <= '0';
		timer_decrement 		 <= '0';	
		
	
		case state_reg is
				
				   when currentTime => 
					currentTime_set 		 <= TASTER1;
					currentTime_increment <= TASTER2;
					currentTime_decrement <= TASTER3;
						
				   when setHourCurrentTime => 
					currentTime_set 		 <= TASTER1;
					currentTime_increment <= TASTER2;
					currentTime_decrement <= TASTER3;
						
					when setMinuteCurrentTime =>
					currentTime_set 		 <= TASTER1;
					currentTime_increment <= TASTER2;
					currentTime_decrement <= TASTER3;
					
					when alarm =>
					alarm_set 		 <= TASTER1;
					alarm_increment <= TASTER2;
					alarm_decrement <= TASTER3;
						
					
					when setHourAlarm =>
					alarm_set 		 <= TASTER1;
					alarm_increment <= TASTER2;
					alarm_decrement <= TASTER3;	
					
					when setMinuteAlarm => 
					alarm_set 		 <= TASTER1;
					alarm_increment <= TASTER2;
					alarm_decrement <= TASTER3;	
					
					when timer =>
					timer_set        <= TASTER1;
					timer_increment  <= TASTER2;
					timer_decrement  <= TASTER3;	
					
					when setHourTimer =>
					timer_set        <= TASTER1;
					timer_increment  <= TASTER2;
					timer_decrement  <= TASTER3;	
					
					when setMinuteTimer => 
					timer_set        <= TASTER1;
					timer_increment  <= TASTER2;
					timer_decrement  <= TASTER3;
					
					when setSecondTimer => 
					timer_set        <= TASTER1;
					timer_increment  <= TASTER2;
					timer_decrement  <= TASTER3;	
					
					when stopwatch =>
					stopwatch_start <= TASTER1;
					stopwatch_clear <= TASTER2;		
					end case;				
			
			
			end process;
end architecture;