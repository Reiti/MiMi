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
	signal pc_int, pc_int_next, pc_out_next : std_logic_vector(PC_WIDTH-1 downto 0);
	signal rd_next, rs_next, rt_next : std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult_next : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wrdata_next : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal zero_next, neg_next : std_logic;
	signal memop_out_next : mem_op_type;
	signal jmpop_out_next : jmp_op_type;
	signal wbop_out_next  :  wb_op_type;
	signal exc_ovf_next   : std_logic;

begin  -- rtl

	exec: process(pc_in, op, memop_in, jmpop_in, wbop_in)
	begin
	
		case op.aluop is
		when others =>
			null;
		end case;
	end process;


	sync:process(clk, reset, stall, flush)
	begin
		if reset = '0' then
			null;
		elsif flush = '0' then
			null;	
		elsif rising_edge(clk) and not stall = '1' then
			--op is a faggot
			
	
			pc_out <= pc_out_next;
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
		end if;
	end process;
end rtl;
