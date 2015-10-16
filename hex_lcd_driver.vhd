library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hex_lcd_driver is
port(
	CLK: in std_logic;

	DIG0: in std_logic_vector(3 downto 0);
	DIG1: in std_logic_vector(3 downto 0);
	DIG2: in std_logic_vector(3 downto 0);
	DIG3: in std_logic_vector(3 downto 0);

	SEVENSEG_SELECT: out std_logic_vector(3 downto 0);
	SEVENSEG_DATA: out std_logic_vector(0 to 7)
);
end entity;

architecture beh of hex_lcd_driver is
--values in 7seg are are A, B, C, D, E, F, G, DP 
begin
	process(clk)
		variable dignum: integer range 0 to 7 := 0;
		variable currentdigit: std_logic_vector(3 downto 0);
		variable clk_div: integer range 0 to 31 := 31;
	begin
		if rising_edge(clk) then
			if clk_div = 31 then --clk_divider is required because 50MHz is too fast to drive seven segment displays. 
				if dignum = 7 then
						dignum := 0;
				else
						dignum := dignum + 1;
				end if;
				
				if dignum = 0 then
					SEVENSEG_SELECT <= "1110";
					currentdigit := DIG0;
				elsif dignum = 2 then
					SEVENSEG_SELECT <= "1101";
					currentdigit := DIG1;
				elsif dignum = 4 then
					SEVENSEG_SELECT <= "1011";
					currentdigit := DIG2;
				elsif dignum = 6 then
					SEVENSEG_SELECT <= "0111";
					currentdigit := DIG3;
				else
					SEVENSEG_SELECT <= "1111"; --this is required so that all digits are "off" during the crossover. Without it, we will have blur across digits
				end if;
				clk_div := 0;
			else
				clk_div := clk_div + 1;
			end if;
			
			
			case currentdigit is
				when "0000" => SEVENSEG_DATA <= "00000011";  --on	on	on	on	on	on	off
				when "0001" => SEVENSEG_DATA <= "10011111";   --off	on	on	off	off	off	off
				when "0010" => SEVENSEG_DATA <= "00100101";  --on	on	off	on	on	off	on
				when "0011" => SEVENSEG_DATA <= "00001101";    --on	on	on	on	off	off	on
				when "0100" => SEVENSEG_DATA <= "10011001";    --off	on	on	off	off	on	on
				when "0101" => SEVENSEG_DATA <= "01001001";    --on	off	on	on	off	on	on
				when "0110" => SEVENSEG_DATA <= "01000001";    --on	off	on	on	on	on	on
				when "0111" => SEVENSEG_DATA <= "00011111";    --on	on	on	off	off	off	off
				when "1000" => SEVENSEG_DATA <= "00000001";    --on on on on on on on 
				when "1001" => SEVENSEG_DATA <= "00001001";    --on	on	on	on	off	on	on
				when "1010" => SEVENSEG_DATA <= "00010001";    --on	on	on	off	on	on	on
				when "1011" => SEVENSEG_DATA <= "11000001";    --off	off	on	on	on	on	on
				when "1100" => SEVENSEG_DATA <= "01100011";    --on	off	off	on	on	on	off
				when "1101" => SEVENSEG_DATA <= "10000101";    --off	on	on	on	on	off	on
				when "1110" => SEVENSEG_DATA <= "01100001";    --on	off	off	on	on	on	on
				when others => SEVENSEG_DATA <= "01110001"; --on	off	off	off	on	on	on
			end case;
		end if;
	end process;

end architecture;

