library ieee; 
use ieee.std_logic_1164.all;


entity frequency_divider is
	Port ( clk      : in std_logic;
			 clk1Hz   : out std_logic;
			 clk100Hz : out std_logic;
			 clk1kHz  : out std_logic);
end frequency_divider;

architecture Behavioral of frequency_divider is
	signal clk1Hz_temp, clk100Hz_temp, clk1kHz_temp : std_logic := '1';
	signal count1Hz, count100Hz, count1kHz : integer := 0;

	--50MHz to 1Hz, 100Hz, 1kHz
begin
	process(clk) begin  
		if rising_edge(clk) then
			count1Hz <= count1Hz + 1;
			count100Hz <= count100Hz + 1;
			count1kHz <= count1kHz + 1;
			
			if(count1Hz = 24999999) then
			  clk1Hz_temp <= not clk1Hz_temp;
			  count1Hz <= 0;
			 end if;
			if(count100Hz = 249999) then
			  clk100Hz_temp <= not clk100Hz_temp;
			  count100Hz <= 0;
			 end if;
			if(count1kHz = 24999) then
			  clk1kHz_temp <= not clk1kHz_temp;
			  count1kHz <= 0;
			 end if;
			
		end if;
		clk1Hz <= clk1Hz_temp;
		clk100Hz <= clk100Hz_temp;
		clk1kHz <= clk1kHz_temp;
   end process;

end Behavioral;