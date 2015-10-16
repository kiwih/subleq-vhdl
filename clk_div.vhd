library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_div is
generic(
	CLOCK_DIVIDE : integer := 5000000
);
port (
	CLK_50: 		in std_logic;
	CLK_SLOW: 	out std_logic
);
end entity clk_div;

architecture beh of clk_div is

begin
--	clk_out <= clk_in;
	process (CLK_50)
		variable count: integer range 0 to (CLOCK_DIVIDE - 1) := 0;
	begin
		if(rising_edge(CLK_50)) then
			if(count = (CLOCK_DIVIDE - 1)) then
				count := 0;
				CLK_SLOW <= '1';
			else
				CLK_SLOW <= '0';
				count := count + 1;
			end if;
		end if;
	end process;
end architecture beh;