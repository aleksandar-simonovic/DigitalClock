library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter24 is
	port(
		reset   : in std_logic;
		set     : in std_logic;
		clock   : in std_logic;							--50Mhz
		enable  : in std_logic;							--1Hz
		dataIn  : in std_logic_vector(7 downto 0);
		dataOut : out std_logic_vector(7 downto 0)
	);
end counter24;

architecture behavioural of counter24 is
begin
	process (clock, reset)
		variable count : unsigned(7 downto 0);
	begin
		if reset = '1' then
			count := "00000000";
		elsif (rising_edge(clock)) then
			if set = '1' then
				count := unsigned(dataIn);
			elsif enable = '1' then
				if count = "00010111" then
					count := "00000000";	
				else
					count := count + 1;
				end if;
			end if;
		end if;
		dataOut <= std_logic_vector(count);
	end process;
end behavioural;