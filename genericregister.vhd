library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity genericregister is
generic (
	NUMBITS: integer := 16
	);
port(
	CLK: in std_logic;
	EN: in std_logic;
	RESET: in std_logic;
	DATA_IN: in std_logic_vector(NUMBITS-1 downto 0);
	DATA_OUT: out std_logic_vector(NUMBITS-1 downto 0)
);
end genericregister;

architecture beh of genericregister is
	signal reg: std_logic_vector(NUMBITS-1 downto 0) := (others => '0');
	
begin
	reg_proc: process(clk, reset)
	begin
		if(RESET = '1') then
			reg <= (others => '0');
		elsif rising_edge(CLK) then
			if EN = '1'  then
				reg <= DATA_IN;
			end if;
		end if;
	end process reg_proc;
	
	DATA_OUT <= reg;
end beh;