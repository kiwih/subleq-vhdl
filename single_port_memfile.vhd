library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--comment to go here

entity single_port_memfile is
generic(
	ADDR_WIDTH : 		integer := 4;
	DATA_WIDTH :		integer := 16;
	MEM_LENGTH : 		integer := 128
);
port(
	CLK: in std_logic;
	
	WRITE_EN: 	in std_logic;
	ADDR: 		in std_logic_vector(ADDR_WIDTH - 1 downto 0);
	DATA_IN: 	in std_logic_vector(DATA_WIDTH - 1 downto 0);
	DATA_OUT: 	out std_logic_vector(DATA_WIDTH - 1 downto 0)
);
end entity;

architecture beh of single_port_memfile is
	type memory_type is array(0 to MEM_LENGTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal memory : memory_type := (
	0 => x"01F001",
	1 => x"000002",
	2 => x"02F004",
	3 => x"000002",
	4 => x"000000",
--	0 => x"000001",
--	1 => x"000002",
--	2 => x"000003",
--	3 => x"000004",
--	4 => x"000005",
--	5 => x"000000",
	
	others => (others => '0')
	);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if WRITE_EN = '1' then
				memory(to_integer(unsigned(ADDR))) <= DATA_IN;
			end if;
			
		end if;
			
		
	end process;
	
	DATA_OUT <= memory(to_integer(unsigned(ADDR)));

end architecture beh;