library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--comment to go here

entity dual_port_memfile is
generic(
	ADDR_WIDTH : integer := 4;
	DATA_WIDTH : integer := 16;
	MEM_LENGTH : integer := 128
);
port(
	CLK: in std_logic;
	
	WRITE_EN_A: in std_logic;
	ADDR_A: 		in std_logic_vector(ADDR_WIDTH - 1 downto 0);
	DATA_IN_A: 	in std_logic_vector(DATA_WIDTH - 1 downto 0);
	DATA_OUT_A: out std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	WRITE_EN_B: in std_logic;
	ADDR_B: 		in std_logic_vector(ADDR_WIDTH - 1 downto 0);
	DATA_IN_B: 	in std_logic_vector(DATA_WIDTH - 1 downto 0);
	DATA_OUT_B: out std_logic_vector(DATA_WIDTH - 1 downto 0)
);
end entity;

architecture beh of dual_port_memfile is
	type memory_type is array(0 to MEM_LENGTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal memory : memory_type := (
	0 => x"0000",
	1 => x"FFF1", --negative F
	2 => x"0001",
	others => (others => '0')
	);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if WRITE_EN_A = '1' then
				memory(to_integer(unsigned(ADDR_A))) <= DATA_IN_A;
			end if;
			
			if WRITE_EN_B = '1' then
				memory(to_integer(unsigned(ADDR_B))) <= DATA_IN_B;
			end if;
			
		end if;
		DATA_OUT_A <= memory(to_integer(unsigned(ADDR_A)));
		DATA_OUT_B <= memory(to_integer(unsigned(ADDR_B)));
	end process;
		
end architecture beh;