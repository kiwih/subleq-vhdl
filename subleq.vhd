library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.defs.all;

--a one-instruction-set instruction computer

entity subleq is
port(
	CLK_50: in std_logic;
	
	LED: out std_logic_vector(7 downto 2);
	
	SEVENSEG_SEL: out std_logic_vector(3 downto 0); --which 7seg display is active
	SEVENSEG_DAT: out std_logic_vector(0 to 7) 	--what 7seg data should be displayed
);
end entity;

architecture beh of subleq is
	--memory mapped addresses
	constant SEVENSEG_01_ADDR : std_logic_vector := x"F0";
	constant SEVENSEG_23_ADDR : std_logic_vector := x"F1";
	
	signal instruction_memory_addr : 	std_logic_vector(ADDR_BUS_SIZE - 1 downto 0);
	signal instruction_memory_data_out: std_logic_vector(INSTRUCTION_BUS_SIZE - 1 downto 0);
	
	signal data_memory_addr_a : 			std_logic_vector(ADDR_BUS_SIZE - 1 downto 0);
	signal data_memory_data_out_a :		std_logic_vector(DATA_BUS_SIZE - 1 downto 0);
	signal data_a : 							std_logic_vector(DATA_BUS_SIZE - 1 downto 0);
	
	signal data_memory_addr_b : 			std_logic_vector(ADDR_BUS_SIZE - 1 downto 0);
	signal data_memory_data_out_b :		std_logic_vector(DATA_BUS_SIZE - 1 downto 0);
	signal data_memory_write_en_b :		std_logic;
	signal data_b :							std_logic_vector(DATA_BUS_SIZE - 1 downto 0);
	
	signal data_processor_out : 			std_logic_vector(DATA_BUS_SIZE - 1 downto 0);
	
	signal data_write :						std_logic;
	signal sevenseg_01_write : 			std_logic;
	signal sevenseg_23_write : 			std_logic;

	signal sevenseg_01_data : 				std_logic_vector(7 downto 0);
	signal sevenseg_23_data : 				std_logic_vector(7 downto 0);
	
	signal reset :								std_logic;
	signal clk :								std_logic;
	
	signal cur_count : 						std_logic_vector(27 downto 0);
begin
	--LED(7 downto 2) <= not(cur_count(27 downto 22));
	LED(7 downto 2) <= not(cur_count(5 downto 0));
	reset <= '0';
	
	--All the components
	
	clock_divider: entity work.clk_div
		port map(
			CLK_50 =>			CLK_50,
			CLK_SLOW =>			clk
		);

	process(clk)
	begin
		if rising_edge(clk) then
			cur_count <= cur_count + 1;
		end if;
	end process;

	processor_core: entity work.core
		generic map(
			ADDR_SIZE => 							ADDR_BUS_SIZE,
			INSTRUCTION_SIZE => 					INSTRUCTION_BUS_SIZE,
			DATA_SIZE => 							DATA_BUS_SIZE
		)
		port map(
			CLK => 									clk,
			RESET =>									reset,
			
			INSTRUCTION_MEMORY_ADDR => 		instruction_memory_addr,
			INSTRUCTION_MEMORY_DATA_OUT => 	instruction_memory_data_out,
			
			DATA_MEMORY_ADDR_A => 				data_memory_addr_a,
			DATA_MEMORY_DATA_OUT_A => 			data_a,
			
			DATA_MEMORY_ADDR_B => 				data_memory_addr_b,
			DATA_MEMORY_DATA_OUT_B =>	 		data_b,
			DATA_MEMORY_DATA_IN_B => 			data_processor_out,
			DATA_MEMORY_WRITE_EN_B => 			data_write
		);
		
	instruction_memory: entity work.single_port_memfile
		generic map(
			ADDR_WIDTH => 	ADDR_BUS_SIZE,
			DATA_WIDTH => 	INSTRUCTION_BUS_SIZE,
			MEM_LENGTH => 	INSTRUCTION_MEMORY_LENGTH
		)
		port map(
			CLK => 			clk,
	
			WRITE_EN => 	'0',
			ADDR => 			instruction_memory_addr,
			DATA_IN => 		(others => '0'),
			DATA_OUT => 	instruction_memory_data_out
		);
		
	data_memory: entity work.dual_port_memfile
		generic map(
			ADDR_WIDTH => 	ADDR_BUS_SIZE,
			DATA_WIDTH => 	DATA_BUS_SIZE,
			MEM_LENGTH => 	DATA_MEMORY_LENGTH
		)
		port map(
			CLK => 			clk,
			
			WRITE_EN_A => 	'0',
			ADDR_A => 		data_memory_addr_a,
			DATA_IN_A => 	(others => '0'),
			DATA_OUT_A => 	data_memory_data_out_a,
			
			WRITE_EN_B => 	data_memory_write_en_b,
			ADDR_B => 		data_memory_addr_b,
			DATA_IN_B => 	data_processor_out,
			DATA_OUT_B => 	data_memory_data_out_b
		);
		
	seg01 : entity work.genericregister
		generic map(
			NUMBITS => 		8
		)
		port map(
			CLK =>			clk,
			EN	=>				sevenseg_01_write,
			RESET =>			reset,
			DATA_IN =>		data_processor_out(7 downto 0),
			DATA_OUT =>		sevenseg_01_data
		);
		
	seg23 : entity work.genericregister
		generic map(
			NUMBITS => 		8
		)
		port map(
			CLK =>			clk,
			EN	=>				sevenseg_23_write,
			RESET =>			reset,
			DATA_IN =>		data_processor_out(7 downto 0),
			DATA_OUT =>		sevenseg_23_data
		);
		
	segdecoder : entity work.hex_lcd_driver
		port map(
			CLK => 					CLK_50,								--needs fast clock due to persistence of vision

			DIG0 => 					sevenseg_01_data(3 downto 0),
			DIG1 => 					sevenseg_01_data(7 downto 4),
			DIG2 => 					instruction_memory_addr(3 downto 0),
			DIG3 => 					instruction_memory_addr(7 downto 4),

			SEVENSEG_SELECT => 	SEVENSEG_SEL,
			SEVENSEG_DATA => 		SEVENSEG_DAT
		);
		
	--the address translation stuff
	
	data_memory_write_en_b 	<= '1' when data_memory_addr_b < DATA_MEMORY_LENGTH and data_write = '1' else '0';
	sevenseg_01_write 		<= '1' when data_memory_addr_b = SEVENSEG_01_ADDR and data_write = '1' else '0';
	sevenseg_23_write 		<= '1' when data_memory_addr_b = SEVENSEG_23_ADDR and data_write = '1' else '0';
	
	data_a <= 
		data_memory_data_out_a when data_memory_addr_a < DATA_MEMORY_LENGTH else
		x"00" & sevenseg_01_data when data_memory_addr_a = SEVENSEG_01_ADDR else
		x"00" & sevenseg_23_data when data_memory_addr_a = SEVENSEG_23_ADDR else
		(others => '0');
	
	data_b <= 
		data_memory_data_out_b when data_memory_addr_b < DATA_MEMORY_LENGTH else
		x"00" & sevenseg_01_data when data_memory_addr_b = SEVENSEG_01_ADDR else
		x"00" & sevenseg_23_data when data_memory_addr_b = SEVENSEG_23_ADDR else
		(others => '0');
	
end architecture beh;
