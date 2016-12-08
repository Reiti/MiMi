library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.core_pack.all;
use work.op_pack.all;

entity decode is
	
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
		wraddr     : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : in  std_logic;
		pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
		exec_op    : out exec_op_type;
		cop0_op    : out cop0_op_type;
		jmp_op     : out jmp_op_type;
		mem_op     : out mem_op_type;
		wb_op      : out wb_op_type;
		exc_dec    : out std_logic);

end decode;

architecture rtl of decode is
	constant OPCODE_WIDTH : integer := 6;

	signal instr_int : std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal pc_int,pc_int_next : std_logic_vector(PC_WIDTH-1 downto 0);
	signal wraddr_int : std_logic_vector(REG_BITS-1 downto 0);
	signal wrdata_int : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal regwrite_int : std_logic;
	signal exec_op_next    : exec_op_type;
	signal jmp_op_next     : jmp_op_type;
	signal mem_op_next     : mem_op_type;
	signal wb_op_next      : wb_op_type;


	signal rdaddr1, rdaddr2 : std_logic_vector(REG_BITS-1 downto 0);
	signal rddata1, rddata2 : std_logic_vector(DATA_WIDTH-1 downto 0);


begin  -- rtl

	exc_dec <= '0';
	-- FIXME: implement exception

	registers:entity work.regfile
	port map(clk => clk, reset => reset, stall => stall, rdaddr1 => rdaddr1,
		rdaddr2 => rdaddr2, rddata1 => rddata1, rddata2 => rddata2,
		wraddr => wraddr_int, wrdata => wrdata_int, regwrite => regwrite_int);

	exec_op.readdata1 <= rddata1;
	exec_op.readdata2 <= rddata2;

	decode:process(instr_int, pc_int, wraddr, wrdata, regwrite)
	variable opcode : std_logic_vector(OPCODE_WIDTH-1 downto 0);
	variable rs,rt,rd : std_logic_vector(REG_BITS-1 downto 0);
	begin
		opcode := instr_int(31 downto 26);
		rs := instr_int(25 downto 21);
		rt := instr_int(20 downto 16);
		rd := instr_int(15 downto 11);

		pc_int_next <= pc_int;

		-- EXEC
		exec_op_next <= EXEC_NOP;
		exec_op_next.rs <= rs;
		exec_op_next.rt <= rt;
		exec_op_next.rd <= rd;
		exec_op_next.imm(15 downto 0) <= instr_int(15 downto 0);
		exec_op_next.imm(31 downto 16) <= (others => '0');

		-- MEM
		mem_op_next <= MEM_NOP;

		-- JUMP
		jmp_op_next <= JMP_NOP;

		-- WB
		wb_op_next <= WB_NOP;

		case opcode is
		when "000000" | "010000" => -- R-type instruction
			if or_reduce(opcode) = '0' then
				-- ALU instruction
				case instr_int(5 downto 0) is -- function
				when "000000" =>
					exec_op_next.aluop <= ALU_SLL;
					exec_op_next.useamt <= '1';
				when "000010" =>
					exec_op_next.aluop <= ALU_SRL;
					exec_op_next.useamt <= '1';
				when "000011" =>
					exec_op_next.aluop <= ALU_SRA;
					exec_op_next.useamt <= '1';
				when "000100" =>
					exec_op_next.aluop <= ALU_SLL;
				when "000110" =>
					exec_op_next.aluop <= ALU_SRL;
				when "000111" =>
					exec_op_next.aluop <= ALU_SRA;
				when "001000" =>
					null;
					-- pc = rs
				when "001001" =>
					exec_op_next.link <= '1';
					-- rd = pc+4 ; pc = rs
					-- TODO: nochmal nachdenken
				when "100000" =>
					exec_op_next.aluop <= ALU_ADD;
				when "100001" =>
					exec_op_next.aluop <= ALU_ADD;
				when "100010" =>
					exec_op_next.aluop <= ALU_SUB;
				when "100011" =>
					exec_op_next.aluop <= ALU_SUB;
				when "100100" =>
					exec_op_next.aluop <= ALU_AND;
				when "100101" =>
					exec_op_next.aluop <= ALU_OR;
				when "100110" =>
					exec_op_next.aluop <= ALU_XOR;
				when "100111" =>
					exec_op_next.aluop <= ALU_NOR;
				when "101010" =>
					exec_op_next.aluop <= ALU_SLT;
				when "101011" =>
					exec_op_next.aluop <= ALU_SLTU;
				when others =>
					null;
					-- exception?
				end case;
			end if;
			-- ignoring Coprocessor instructions

		when "000010" | "000011" => -- J-type instruction
			if opcode(0) = '1' then
				exec_op_next.rd <= "11111";
				exec_op_next.link <= '1';
			end if;

		-- I-type instructions

		-- Branch Instruction
		when "000100" =>
			exec_op_next.branch <= '1';
			exec_op_next.imm(17 downto 0) <= instr_int(15 downto 0) & "00";
			jmp_op_next <= JMP_BEQ;
		when "000101" =>
			exec_op_next.branch <= '1';
			exec_op_next.imm(17 downto 0) <= instr_int(15 downto 0) & "00";
			jmp_op_next <= JMP_BNE;
		when "000110" =>
			exec_op_next.branch <= '1';
			exec_op_next.imm(17 downto 0) <= instr_int(15 downto 0) & "00";
			jmp_op_next <= JMP_BLEZ;
		when "000111" =>
			exec_op_next.branch <= '1';
			exec_op_next.imm(17 downto 0) <= instr_int(15 downto 0) & "00";
			jmp_op_next <= JMP_BGTZ;

		-- Extra ALU Instructions
		when "001000" =>
			exec_op_next.aluop <= ALU_ADD;
			exec_op_next.useimm <= '1';
		when "001001" =>
			exec_op_next.aluop <= ALU_ADD;
			exec_op_next.useimm <= '1';
		when "001010" =>
			exec_op_next.aluop <= ALU_SLT;
			exec_op_next.useimm <= '1';
		when "001011" =>
			exec_op_next.aluop <= ALU_SLT;
			exec_op_next.useimm <= '1';
		when "001100" =>
			exec_op_next.aluop <= ALU_AND;
			exec_op_next.useimm <= '1';
		when "001101" =>
			exec_op_next.aluop <= ALU_OR;
			exec_op_next.useimm <= '1';
		when "001110" =>
			exec_op_next.aluop <= ALU_XOR;
			exec_op_next.useimm <= '1';
		when "001111" =>
			exec_op_next.aluop <= ALU_LUI;
			exec_op_next.useimm <= '1';
			
		when others =>
			null;
			-- exception
		end case;
	end process;

	sync:process(clk, reset, stall, flush)
	begin
		if reset = '0' then
			null;
		elsif flush = '0' then
			instr_int <= (others => '0');
			pc_int <= (others => '0');
			wraddr_int <= (others => '0');
			wrdata_int <= (others => '0');
			regwrite_int <= '0';
		elsif rising_edge(clk) and not stall = '1' then
			-- latch new values
			instr_int <= instr;
			pc_int <= pc_in;
			wrdata_int <= wrdata;
			wraddr_int <= wraddr;
			regwrite_int <= regwrite;

			-- write decoded info
			pc_out <= pc_int;
			exec_op <= exec_op_next;
			cop0_op <= COP0_NOP;
			jmp_op <= jmp_op_next;
			mem_op <= mem_op_next;
			wb_op <= wb_op_next;

		end if;
	end process;

end rtl;
