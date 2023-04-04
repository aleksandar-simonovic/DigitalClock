library ieee;
use ieee.std_logic_1164.all;

ENTITY BCD7S IS 
PORT(

input_BCD : in std_logic_vector (3 downto 0);
output_7s : out std_logic_vector(6 downto 0) 	--7seg zajednicka anoda ('0' pali diodu)   g,f,e,d,c,b,a
		
);
END ENTITY BCD7S;

ARCHITECTURE BCD7S_arch OF BCD7S IS

BEGIN

	PROCESS(input_BCD)
	BEGIN
		CASE (input_BCD) IS
			WHEN "0000" => output_7s<="1000000";	--0
			WHEN "0001" => output_7s<="1111001";	--1
			WHEN "0010" => output_7s<="0100100";	--2
			WHEN "0011" => output_7s<="0110000";	--3
			WHEN "0100" => output_7s<="0011001";	--4
			WHEN "0101" => output_7s<="0010010";	--5
			WHEN "0110" => output_7s<="0000010";	--6
			WHEN "0111" => output_7s<="1111000";	--7
			WHEN "1000" => output_7s<="0000000";	--8
			WHEN "1001" => output_7s<="0010000";	--9
			WHEN "1010" => output_7s<="0001000";	--A
			WHEN OTHERS => output_7s<="1111111";
		END CASE;
	END PROCESS;

END ARCHITECTURE BCD7S_arch;
