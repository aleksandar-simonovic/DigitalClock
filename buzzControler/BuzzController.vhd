library ieee; 
use ieee.std_logic_1164.all;


entity BuzzController is
	Port(	 
			 clock       : in std_logic;
			 clock1kHz   : in std_logic;
			 clock1Hz   : in std_logic;
		    	 reset       : in std_logic;
			 mode   		 : in std_logic;
			 AlarmBuzzer : in std_logic;
			 TimerBuzzer : in std_logic;
			 Buzz 		 : out std_logic;
			 ModeDisable : out std_logic);
			 
end BuzzController;

architecture Behavior of BuzzController is
	
	type time_sm_type is
		(idle, buzz_state);
	signal state_reg, state_next : time_sm_type; 
	
	
	
begin	
	
	--
	process(clock, reset)
	begin
	
		if(reset = '1') then
			state_reg <= idle;
			
		elsif rising_edge(clock) then
			state_reg <= state_next;
			
		end if;
	end process;
	
	
	process(state_reg, mode)
	
	begin	
		
		case state_reg is
		
			when idle => 
					if(mode = '1') then
						 state_next <= idle;
					elsif( AlarmBuzzer = '1' or TimerBuzzer = '1') then
						 state_next <= buzz_state;
					else 
						 state_next <= idle;
					end if;
					
			 when buzz_state =>
					if(mode = '1') then
						 state_next <= idle;
					else
						 state_next <= buzz_state;
					end if;
			end case;
				
	end process;

	
	process(state_reg)
	begin	
		Buzz <= '0';
		ModeDisable <= '0';
		case state_reg is
			when idle => 
					Buzz <= '0';
					ModeDisable <= '0';
			 when buzz_state =>
					Buzz <= clock1kHz and clock1Hz;
					ModeDisable <= '1';
		end case;
				
	end process;
	
end Behavior;


	
	

			 
			 
			
		