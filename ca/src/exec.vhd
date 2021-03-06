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
	signal aluresult_next : std_logic_vector(DATA_WIDTH-1 downto 0) := (others =>'0');
	signal wrdata_next : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal zero_next, neg_next : std_logic;
	signal exc_ovf_next   : std_logic;

	signal new_pc_next : std_logic_vector(PC_WIDTH-1 downto 0);
	--latches
	signal op_l : exec_op_type;
	signal pc_int: std_logic_vector(PC_WIDTH-1 downto 0);
	signal memop_int : mem_op_type := MEM_NOP;
	signal jmpop_int : jmp_op_type;
	signal wbop_int  : wb_op_type;

	--aluspecific
	signal alu_in1, alu_in2, alu_out : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal alu_Z, alu_V : std_logic;
	signal alu_op : ALU_OP_TYPE;


begin  -- rtl

	alu_inst : entity work.alu
	port map(
		op => alu_op,
		A => alu_in1,
		B => alu_in2,
		R => alu_out,
		Z => alu_Z,
		V => alu_V
	);

	exec: process(pc_int, op_l, memop_int, jmpop_int, wbop_int, alu_out, alu_Z, alu_V, forwardA, forwardB, mem_aluresult, wb_result)
	begin
		rd_next <= op_l.rd;
		rs_next <= op_l.rs;
		rt_next <= op_l.rt;	
		aluresult_next <= alu_out;
		--wrdata_next <= (others => '0');
		wrdata_next <= alu_out; -- wrdata ignored, when not needed
		zero_next <= alu_Z;
		neg_next <= alu_out(DATA_WIDTH-1);--alu_V;

		exc_ovf_next <= alu_V;	

		--std alu operands
		alu_op <= op_l.aluop;
		
		alu_in1 <= op_l.readdata1;
		alu_in2 <= op_l.readdata2;

		if forwardA = FWD_ALU then
			if op_l.branch = '1' then
				alu_in2 <= mem_aluresult;
			else
				alu_in1 <= mem_aluresult;
			end if;
		elsif forwardA = FWD_WB then
			if op_l.branch = '1' then
				alu_in2 <= wb_result;
			else 
				alu_in1 <= wb_result;
			end if;
		end if;

		if forwardB = FWD_ALU then
			alu_in2 <= mem_aluresult;
		elsif forwardB = FWD_WB then
			alu_in2 <= wb_result;
		end if;

		
		-- if needed, jump will jump there, or else its ignored anyway
		new_pc_next <= alu_out(13 downto 0);--std_logic_vector(unsigned(shift_left(unsigned(alu_out(13 downto 0)),2)));	

		if op_l.useamt = '1' then
			alu_in1 <= op_l.imm;
		elsif op_l.useimm = '1' then
			alu_in2 <= op_l.imm;
		end if;

		if op_l.link = '1' then --link! regwrite is active-> pc shoudl go to r31/ jalr rd
			aluresult_next <= std_logic_vector(resize(unsigned(pc_int) +4 , aluresult_next'length));
			--new_pc_next <= std_logic_vector(unsigned(shift_left(unsigned(op_l.imm(13 downto 0)), 2)));
		end if;	
		if (op_l.branch = '1')	then
			new_pc_next <= std_logic_vector(unsigned(pc_int) +
											unsigned(shift_left(unsigned(op_l.imm(13 downto 0)), 2)));
		end if;
		if(op_l.regdst ='1') then
			wrdata_next <= op_l.readdata2;		
			if forwardB = FWD_ALU then
			    wrdata_next <= mem_aluresult;
			elsif forwardB = FWD_WB then
			    wrdata_next <= wb_result;
			end if;
		end if;	
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
	memop_out <= memop_int;
	jmpop_out <= jmpop_int;
	wbop_out <= wbop_int;
	exc_ovf <= exc_ovf_next;
	
	new_pc <= new_pc_next;

	sync:process(clk, reset, stall, flush, op, pc_in, memop_in, jmpop_in, wbop_in)
	begin
		if reset = '0' or flush = '1' then
			op_l <= EXEC_NOP;
			memop_int <= MEM_NOP;
			wbop_int <= WB_NOP;
		elsif (rising_edge(clk) and not stall = '1') then
			--latch new values
			op_l<=op;
			pc_int <= pc_in;
			memop_int <= memop_in;
			jmpop_int <= jmpop_in;
			wbop_int <= wbop_in;
		end if;
	end process;
end rtl;
