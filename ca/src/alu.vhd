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
		V <= '0';
		if sA = 0 then
			Z <= '1';
		else
			Z <= '0';
		end if;
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
				R <= std_logic_vector(shift_left(uB, to_integer(uA(DATA_WIDTH_BITS-1 downto 0))));
			when ALU_SRL => 
				R <= std_logic_vector(shift_right(uB, to_integer(uA(DATA_WIDTH_BITS-1 downto 0))));
			when ALU_SRA => 
				R <= to_stdlogicvector(to_bitvector(B) sra to_integer(uA(DATA_WIDTH_BITS-1 downto 0)));
			when ALU_ADD => 
				R <= std_logic_vector(sA + sB);
				if (sA >= 0) and (sB >= 0) and ((sA + sB) < 0) then
					V <= '1';
				elsif (sA < 0) and (sB < 0) and ((sA + sB) >= 0) then
					V <= '1';
				end if;
			when ALU_SUB => 
				R <= std_logic_vector(sA - sB);
				if sA = sB then
					Z <= '1';
				else
					Z <= '0';
				end if;
				if (sA >= 0) and (sB < 0) and ((sA - sB) < 0) then
					V <= '1';
				elsif (sA < 0) and (sB >= 0) and ((sA - sB) >= 0) then
					V <= '1';
				end if;
			when ALU_AND => 
				R <= A and B;
			when ALU_OR => 
				R <= A or B;
			when ALU_XOR => 
				R <= A xor B;
			when ALU_NOR => 
				R <= not(A or B);
		end case;
	end process;
end rtl;
