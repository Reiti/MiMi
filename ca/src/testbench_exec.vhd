library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_exec is
end entity;


architecture beh of testbench_exec is
 	constant CLK_PERIOD: time := 20 ns; 
	
	signal	clk, reset       :  std_logic;
	signal	stall      		 :  std_logic;
	signal	flush            :  std_logic;
	signal	pc_in            :  std_logic_vector(PC_WIDTH-1 downto 0);
	signal	op	   	         :  exec_op_type;
	signal	pc_out           :  std_logic_vector(PC_WIDTH-1 downto 0);
	signal	rd, rs, rt       :  std_logic_vector(REG_BITS-1 downto 0);
	signal	aluresult	     :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal	wrdata           :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal	zero, neg        :  std_logic;
	signal	new_pc           :  std_logic_vector(PC_WIDTH-1 downto 0);		
	signal	memop_in         :  mem_op_type;
	signal	memop_out        :  mem_op_type;
	signal	jmpop_in         :  jmp_op_type;
	signal	jmpop_out        :  jmp_op_type;
	signal	wbop_in          :  wb_op_type;
	signal	wbop_out         :  wb_op_type;
	signal	forwardA         :  fwd_type;
	signal	forwardB         :  fwd_type;
	signal	cop0_rddata      :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal	mem_aluresult    :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal	wb_result        :  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal	exc_ovf          :  std_logic;

	

begin	
	exec_inst: entity work.exec
		port map
		(
		clk => clk, 
		reset  =>reset,    
		stall => '0',      
		flush => '0',       
		pc_in => pc_in,       
		op	  => op, 	        
		pc_out => pc_out,        
		rd => rd, rs =>rs, rt=>rt,
		aluresult=> aluresult, 
		wrdata => wrdata,       
		zero => zero, neg =>neg, 
		new_pc  => new_pc, 
		memop_in => memop_in,  
		memop_out => memop_out, 
		jmpop_in =>jmpop_in,     
		jmpop_out => jmpop_out,   
		wbop_in => wbop_in,
		wbop_out => wbop_out,    
		forwardA => forwardA,     
		forwardB => forwardB,      
		cop0_rddata => cop0_rddata, 
		mem_aluresult => mem_aluresult,
		wb_result => wb_result,
		exc_ovf => exc_ovf
		);
  clk_gen: process is
  begin
    clk <= '1';
    wait for CLK_PERIOD/2;
    clk <= '0';
    wait for CLK_PERIOD/2;
  end process;

  rs_gen: process is
  begin
    reset <= '0';
    wait for 2*CLK_PERIOD;
    reset <= '1';
    wait;
  end process;


	exec_test: process
	begin
		wait until rising_edge(reset);
		wait for 2*CLK_PERIOD;	
		pc_in <= std_logic_vector(to_unsigned(8, pc_in'length));
		op.aluop <= ALU_SUB;
		op.readdata1 <= x"00000101";
		op.readdata2 <= x"00000000";
		op.imm <= x"00000002";
		op.rs <="00000";
		op.rt <="00001";
		op.rd <="00010";
		op.useimm <= '0';
		op.useamt <= '0';
		op.link <= '1';
		op.branch <= '1';
		op.regdst <= '0';
		op.cop0 <= '0';
		op.ovf <= '0';	
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
	end process;
end beh;
