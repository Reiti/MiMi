library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity exec is
	
	port (
		clk, reset       : in  std_logic;
		stall      		 : in  std_logic;
		flush            : in  std_logic;
		pc_in            : in  std_logic_vector(PC_WIDTH-1 downto 0);
		op	   	         : in  exec_op_type;
		pc_out           : out std_logic_vector(PC_WIDTH-1 downto 0);
		rd, rs, rt       : out std_logic_vector(REG_BITS-1 downto 0);
		aluresult	     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wrdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
		zero, neg         : out std_logic;
		new_pc           : out std_logic_vector(PC_WIDTH-1 downto 0);		
		memop_in         : in  mem_op_type;
		memop_out        : out mem_op_type;
		jmpop_in         : in  jmp_op_type;
		jmpop_out        : out jmp_op_type;
		wbop_in          : in  wb_op_type;
		wbop_out         : out wb_op_type;
		forwardA         : in  fwd_type;
		forwardB         : in  fwd_type;
		cop0_rddata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		exc_ovf          : out std_logic);

end exec;

architecture rtl of exec is
	signal rd_next, rs_next, rt_next : std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult_next : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wrdata_next : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal zero_next, neg_next : std_logic;
	signal memop_out_next : mem_op_type;
	signal jmpop_out_next : jmp_op_type;
	signal wbop_out_next  :  wb_op_type;
	signal exc_ovf_next   : std_logic;
	--latches
	signal op_l : exec_op_type;
	signal pc_int: std_logic_vector(PC_WIDTH-1 downto 0);
	signal memop_int : mem_op_type;
	signal jmpop_int : jmp_op_type;
	signal wbop_int  : wb_op_type;

	--aluspecific
	signal input1, input2, alu_out : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal alu_Z, alu_V : std_logic;

begin  -- rtl

	alu_inst : entity work.alu
	port map(
		op => op_l.aluop,
		A => input1,
		B => input2,
		R => alu_out,
		Z => alu_Z,
		V => alu_V
	);

	exec: process(pc_int, op_l, memop_int, jmpop_int, wbop_int)
	begin
		rd_next <= op.rd;
		rs_next <= op.rs;
		rt_next <= op.rt;	
		aluresult_next <= (others => '0');
		wrdata_next <= (others => '0');
		zero_next <= '0';
		neg_next <= '0';
		-- MEM
		memop_out_next <= MEM_NOP;
		-- JUMP
		jmpop_out_next <= JMP_NOP;
		-- WB
		wbop_out_next <= WB_NOP;
		
		exc_ovf_next <= '0';		

		case op.aluop is
		when ALU_NOP =>
			null;
		when ALU_SLT =>
			null;
		when ALU_SLTU =>
			null;
		when ALU_SLL =>
			null;
		when ALU_SRL =>
			null;
		when ALU_SRA =>
			null;
		when ALU_ADD =>
			null;
		when ALU_SUB =>
			null;
		when ALU_AND =>
			null;
		when ALU_OR =>
			null;
		when ALU_XOR =>
			null;
		when ALU_NOR =>
			null;
		when ALU_LUI => 
			null;
		when others =>
			null;
		end case;
	end process;

--write new values:
	pc_out <= pc_int;
	rd <= rd_next;
	rs <= rs_next;
	rt <= rt_next;
	aluresult <= aluresult_next;
	wrdata <= wrdata_next;
	zero <= zero_next;
	neg <= neg_next;
	memop_out <= memop_out_next;
	jmpop_out <= jmpop_out_next;
	wbop_out <= wbop_out_next;
	exc_ovf <= exc_ovf_next;

	sync:process(clk, reset, stall, flush)
	begin
		if reset = '0' then
			null;
		elsif flush = '0' then
			null;	
		elsif rising_edge(clk) and not stall = '1' then
			--latch new values
			op_l<=op;
			pc_int <= pc_in;
			memop_int <= memop_in;
			jmpop_int <= jmpop_in;
			wbop_int <= wbop_in;

	 	
		end if;
	end process;
end rtl;
