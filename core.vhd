library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

--A single-cycle core for running a one-instruction computer
--Instructions are 24 bits
--[00000000] [00000000] [00000000] 
-- A          B          C      
--Executes 
----(1) [B] = [B] - [A] 
----(2) if [B] - [A] <= 0 GOTO C

entity core is 
generic(
	ADDR_SIZE : 			integer := 8;
	INSTRUCTION_SIZE : 	integer := 24;		--should be 3x ADDR_SIZE
	DATA_SIZE: 				integer := 16
);
port(
	CLK : in std_logic;
	RESET : in std_logic;
	
	INSTRUCTION_MEMORY_ADDR : 		out std_logic_vector(ADDR_SIZE - 1 downto 0);
	INSTRUCTION_MEMORY_DATA_OUT: 	in std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
	
	DATA_MEMORY_ADDR_A : 			out std_logic_vector(ADDR_SIZE - 1 downto 0);
	DATA_MEMORY_DATA_OUT_A : 		in std_logic_vector(DATA_SIZE - 1 downto 0);
	
	DATA_MEMORY_ADDR_B : 			out std_logic_vector(ADDR_SIZE - 1 downto 0);
	DATA_MEMORY_DATA_OUT_B :		in std_logic_vector(DATA_SIZE - 1 downto 0);
	DATA_MEMORY_DATA_IN_B : 		out std_logic_vector(DATA_SIZE - 1 downto 0);
	DATA_MEMORY_WRITE_EN_B :		out std_logic
	
);
end entity core;

architecture beh of core is
	signal pc : 						std_logic_vector(ADDR_SIZE - 1 downto 0) := (others => '0');
	signal current_instruction : 	std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
	signal op_a :						std_logic_vector(INSTRUCTION_SIZE/3 - 1 downto 0);
	signal op_b :						std_logic_vector(INSTRUCTION_SIZE/3 - 1 downto 0);
	signal op_c :						std_logic_vector(INSTRUCTION_SIZE/3 - 1 downto 0);
	
	signal data_a :					std_logic_vector(DATA_SIZE - 1 downto 0);
	signal data_b :					std_logic_vector(DATA_SIZE - 1 downto 0);
	signal data_out : 				std_logic_vector(DATA_SIZE - 1 downto 0);
	
begin
	INSTRUCTION_MEMORY_ADDR 		<= pc;

	current_instruction 				<= INSTRUCTION_MEMORY_DATA_OUT;
	
	op_c <= current_instruction(1 * INSTRUCTION_SIZE/3 - 1 downto 0 * INSTRUCTION_SIZE/3);
	op_b <= current_instruction(2 * INSTRUCTION_SIZE/3 - 1 downto 1 * INSTRUCTION_SIZE/3);
	op_a <= current_instruction(3 * INSTRUCTION_SIZE/3 - 1 downto 2 * INSTRUCTION_SIZE/3);
	
--	op_c <= current_instruction(7 downto 0);
--	op_b <= current_instruction(15 downto 8);
--	op_a <= current_instruction(23 downto 16);
	
	DATA_MEMORY_ADDR_A 		<= op_a;
	DATA_MEMORY_ADDR_B 		<= op_b;
	DATA_MEMORY_WRITE_EN_B 	<= '1';
	DATA_MEMORY_DATA_IN_B	<= data_out;
	
	data_a <= DATA_MEMORY_DATA_OUT_A;
	data_b <= DATA_MEMORY_DATA_OUT_B;
	data_out <= data_b - data_a;
	
	process(CLK)
	
	begin
		if rising_edge(CLK) then
			
			if RESET = '1' then
				pc <= (others => '0');
			elsif (data_b - data_a) <= 0 then
				pc <= op_c;
			else
				pc <= pc + 1;
			end if;
		end if;
		
	end process;

end architecture;