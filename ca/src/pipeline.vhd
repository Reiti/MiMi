library ieee;
use ieee.std_logic_1164.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline is
	
	port (
		clk, reset : in	 std_logic;
		mem_in     : in  mem_in_type;
		mem_out    : out mem_out_type;
		intr       : in  std_logic_vector(INTR_COUNT-1 downto 0));

end pipeline;

architecture rtl of pipeline is
--fetch
		signal stall       : std_logic;
		signal pcsrc	   : std_logic;
		signal pc_in	   : std_logic_vector(PC_WIDTH-1 downto 0);
		--signal pc_out	   : std_logic_vector(PC_WIDTH-1 downto 0);i
		signal pc_fetch	   : std_logic_vector(PC_WIDTH-1 downto 0);
		signal instr	   : std_logic_vector(INSTR_WIDTH-1 downto 0);
	
--decode
		signal wraddr     : std_logic_vector(REG_BITS-1 downto 0);
		signal wrdata     : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal regwrite   : std_logic;
		--signal pc_out     : std_logic_vector(PC_WIDTH-1 downto 0);
		signal pc_decode  : std_logic_vector(PC_WIDTH-1 downto 0);
		signal exec_op    : exec_op_type;
		signal cop0_op    : cop0_op_type;
		signal jmp_op     : jmp_op_type;
		signal mem_op     : mem_op_type;
		signal wb_op      : wb_op_type;
		signal exc_dec    : std_logic;

--exec
		signal op	   	         : exec_op_type;
		signal rd, rs, rt       : std_logic_vector(REG_BITS-1 downto 0);
		signal aluresult	     : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal new_pc           : std_logic_vector(PC_WIDTH-1 downto 0);
		signal pc_exec           : std_logic_vector(PC_WIDTH-1 downto 0);		
		signal exec_memop        : mem_op_type;
		signal exec_jmpop        : jmp_op_type;
		signal exec_wbop         : wb_op_type;
		signal forwardA         : fwd_type;
		signal forwardB         : fwd_type;
		signal cop0_rddata      : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal mem_aluresult    : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal exc_ovf          : std_logic;
		signal exec_wrdata		: std_logic_vector(DATA_WIDTH-1 downto 0);
--mem
--flush
		signal rd_in         : std_logic_vector(REG_BITS-1 downto 0);
		signal aluresult_in  : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal zero, neg     : std_logic;
		signal new_pc_mem     : std_logic_vector(PC_WIDTH-1 downto 0);
		signal pc_mem	     : std_logic_vector(PC_WIDTH-1 downto 0);
		signal mem_rd        : std_logic_vector(REG_BITS-1 downto 0);
		signal aluresult_mem : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal memresult     : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal mem_wbop       : wb_op_type;
		signal exc_load      : std_logic;
		signal exc_store     : std_logic;
--wb
		signal wb_result     : std_logic_vector(DATA_WIDTH-1 downto 0);
		signal wb_rd      : std_logic_vector(REG_BITS-1 downto 0);
begin  -- rtl
	
	fetch_inst: entity work.fetch
	port map(
		clk => clk,
		reset => reset,	
		stall => mem_in.busy,

		pcsrc => pcsrc,
		pc_in => new_pc_mem,

		pc_out => pc_fetch,
		instr => instr	
	);

	decode_inst: entity work.decode
	port map(
		clk => clk,
		reset => reset,
		stall => mem_in.busy,
		flush => '0',

		pc_in => pc_fetch,
		instr => instr,
		--wraddr => wraddr, --check!
		wraddr => wb_rd,
		--wrdata => wrdata, --tocheck
		wrdata => wb_result,
		regwrite => regwrite, --tocheck-sollt passn
		pc_out => pc_decode,
		exec_op => exec_op,
		cop0_op => cop0_op,
		jmp_op => jmp_op,
		mem_op => mem_op,
		wb_op => wb_op,
		exc_dec => exc_dec
	);

	exec_inst: entity work.exec
	port map(
		clk => clk,
		reset => reset,
		stall => mem_in.busy,
		flush => '0',

		op => exec_op,
		rd =>rd, 
		rs =>rs,--? 
		rt => rt,  --?
		aluresult => aluresult,

		wrdata => exec_wrdata,
		zero => zero,
		neg => neg,
		new_pc => new_pc,		
		pc_in => pc_decode,	
		pc_out => pc_exec,	
		memop_in => mem_op,
		memop_out=> exec_memop,
		jmpop_in=> jmp_op,
		jmpop_out => exec_jmpop,
		wbop_in => wb_op,
		wbop_out => exec_wbop,

		
--todo?
		mem_aluresult => mem_aluresult, --can be ignored
		wb_result => wb_result, --can be ignored
		forwardA => forwardA, --can be ignored
		forwardB => forwardB, --can be ignored
		cop0_rddata => cop0_rddata,
		exc_ovf => exc_ovf
	);

	mem_inst: entity work.mem
	port map(
		clk => clk,
		reset => reset,
		stall => mem_in.busy,
		flush => '0',

		mem_op=> exec_memop,
		jmp_op=> exec_jmpop,
		wrdata => exec_wrdata,
		memresult =>memresult,
		zero => zero, 
		neg => neg,
		pcsrc=>pcsrc,
		new_pc_in => new_pc,
		new_pc_out => new_pc_mem,
		pc_in =>pc_exec,
		pc_out => pc_mem,
		rd_in => rd,
		rd_out  =>mem_rd,
		aluresult_in =>aluresult,
		aluresult_out => mem_aluresult,
		wbop_in => exec_wbop,
		wbop_out => mem_wbop,
		mem_out => mem_out, --pipe mems
		mem_data => mem_in.rddata, --pipedata
	
		exc_load => exc_load,
		exc_store => exc_store
	);	

	wb_inst: entity work.wb
	port map(
		clk => clk,
		reset => reset,
		stall => mem_in.busy,
		flush => '0',

		op	=> mem_wbop,
		aluresult => mem_aluresult,
		memresult  => memresult,
		result => wb_result,
		regwrite  => regwrite,	
		rd_in  =>mem_rd,
		rd_out => wb_rd
	);

	fwd_inst: entity work.fwd
	port map(
		forwardA => forwardA,
		forwardB => forwardB,
		exec_rs => rs,
		exec_rt => rt,
		mem_rd => mem_rd,
		wb_rd => wb_rd
	);


end rtl;












































