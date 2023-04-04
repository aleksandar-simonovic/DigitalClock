library ieee;
use ieee.std_logic_1164.all;

entity edgeDetector is
	port
	(
		clk, reset : in std_logic;
		strobe 	  : in std_logic;
		p2			  : out std_logic
	);
end edgeDetector;

architecture multi_seg_mealy_fsm_arch of edgeDetector is

	type mc_sm_type is
		(zero, one);
		
	signal state_next, state_reg : mc_sm_type;
	
begin

	
	--state register
	process(clk, reset)
	begin
		if (reset = '1') then
			state_reg <= zero;   
		elsif rising_edge(clk) then					
			state_reg <= state_next;
		end if;	
	end process;
	
	
	
	--next state logic
	process(state_reg, strobe)
	begin
		case state_reg is
			when zero =>
				if (strobe = '1') then	
					state_next <= one;
				else
					state_next <= zero;
				end if;
			when one =>
				if (strobe = '1') then    
					state_next <= one;
				else
					state_next <= zero;
				end if;
		end case;
	end process;
	
	
	
	--Mealy output logic
	process(state_reg, strobe)
	begin
		p2 <= '0';
		case state_reg is
			when zero =>
				if(strobe = '1') then
					p2 <= '1';
				end if;
			when one =>
				--nop
		end case;
	end process;

end multi_seg_mealy_fsm_arch;
