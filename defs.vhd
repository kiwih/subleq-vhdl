library ieee;
use ieee.std_logic_1164.all;

package defs is
	constant ADDR_BUS_SIZE : 					integer := 8;
	constant INSTRUCTION_BUS_SIZE : 			integer := 24;
	constant DATA_BUS_SIZE : 					integer := 16;
	constant INSTRUCTION_MEMORY_LENGTH : 	integer := 128;
	constant DATA_MEMORY_LENGTH : 			integer := 128;

end defs;