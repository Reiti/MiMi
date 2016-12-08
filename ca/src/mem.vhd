library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mem is
	
	port (
		clk, reset    : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;
		mem_op        : in  mem_op_type;
		jmp_op        : in  jmp_op_type;
		pc_in         : in  std_logic_vector(PC_WIDTH-1 downto 0);
		rd_in         : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wrdata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		zero, neg     : in  std_logic;
		new_pc_in     : in  std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out        : out std_logic_vector(PC_WIDTH-1 downto 0);
		pcsrc         : out std_logic;
		rd_out        : out std_logic_vector(REG_BITS-1 downto 0);
		aluresult_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		new_pc_out    : out std_logic_vector(PC_WIDTH-1 downto 0);
		wbop_in       : in  wb_op_type;
		wbop_out      : out wb_op_type;
		mem_out       : out mem_out_type;
		mem_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		exc_load      : out std_logic;
		exc_store     : out std_logic);

end mem;

architecture rtl of mem is
	signal pc_in_int, new_pc_in_int: std_logic_vector(PC_WIDTH-1 downto 0);
	signal rd_in_int: std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult_in_int: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wbop_in_int: wb_op_type;
	signal mem_op_int: mem_op_type;
	signal wrdata_int: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_data_int: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal jmp_op_int: jmp_op_type;
	signal neg_int, zero_int: std_logic;

begin  -- rtl

	pc_out <= pc_in_int;
	rd_out <= rd_in_int;
	aluresult_out <= aluresult_in_int;
	new_pc_out <= new_pc_in_int;
	wbop_out <= wbop_in_int;

	memo: entity work.memu
	port map
	(
		op => mem_op_int,
		A => aluresult_in_int(ADDR_WIDTH-1 downto 0),
		W => wrdata_int,
		D => mem_data_int,
		M => mem_out,
		R => memresult,
		XL => exc_load,
		XS => exc_store
	);

	jmp: entity work.jmpu
	port map
	(
		op => jmp_op_int,
		N => neg_int,
		Z => zero_int,
		J => pcsrc
	);
	
	latch: process(clk, reset, pc_in, new_pc_in, rd_in, aluresult_in, wbop_in, mem_op, wrdata, mem_data) is
	begin
		if reset = '0' or flush = '1' then
			pc_in_int <= (others => '0');
			new_pc_in_int <= (others => '0');
			rd_in_int <= (others => '0');
			aluresult_in_int <= (others => '0');
			wbop_in_int <= WB_NOP; 
			mem_op_int <= MEM_NOP;
			wrdata_int <= (others => '0');
			mem_data_int <= (others => '0');
			neg_int <= '0';
			zero_int <= '0';
			jmp_op_int <= JMP_NOP;
		elsif rising_edge(clk) and (not(stall = '1')) then
			pc_in_int <= pc_in;
			new_pc_in_int <= new_pc_in;
			rd_in_int <= rd_in;
			aluresult_in_int <= aluresult_in;
			wbop_in_int <= wbop_in;
			mem_op_int <= mem_op;
			wrdata_int <= wrdata;
			mem_data_int <= mem_data;
			neg_int <= neg;
			zero_int <= zero;
			jmp_op_int <= jmp_op;
		end if;
		if stall = '1' then
			mem_op_int.memread <= '0';
			mem_op_int.memwrite <= '0';
		end if;
	end process;


end rtl;
