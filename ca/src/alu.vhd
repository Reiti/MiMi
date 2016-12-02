library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		Z    : out std_logic;
		V    : out std_logic);

end alu;

architecture rtl of alu is

	signal sA: signed(DATA_WIDTH-1 downto 0);
	signal sB: signed(DATA_WIDTH-1 downto 0);
	signal uA: unsigned(DATA_WIDTH-1 downto 0);
	signal uB: unsigned(DATA_WIDTH-1 downto 0);
begin  -- rtl
	sA <= signed(A);
	sB <= signed(B);
	uA <= unsigned(A);
	uB <= unsigned(B);
	calc_result: process(op, sA, sB, uA, uB, A, B)
	begin
		case op is
			when ALU_NOP =>
				R <= A;
			when ALU_LUI =>
				R <= std_logic_vector(shift_left(uB, 16));
			when ALU_SLT =>
				if sA < sB then
					R <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
				else
					R <= std_logic_vector(to_unsigned(0, DATA_WIDTH));
				end if;	
			when ALU_SLTU =>
				if uA < uB then
					R <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
				else
					R <= std_logic_vector(to_unsigned(0, DATA_WIDTH));
				end if;	
			when ALU_SLL => 
				R <= std_logic_vector(shift_left(uB, to_integer(uA)));
			when ALU_SRL => 
				R <= std_logic_vector(shift_left(uB, to_integer(uA)));
			when ALU_SRA => 
				R <= to_stdlogicvector(to_bitvector(B) sra to_integer(uA));
			when ALU_ADD => null;
			when ALU_SUB => null;
			when ALU_AND => null;
			when ALU_OR => null;
			when ALU_XOR => null;
			when ALU_NOR => null;
		end case;
	end process;
end rtl;
