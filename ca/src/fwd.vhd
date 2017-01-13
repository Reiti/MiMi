library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.core_pack.all;
use work.op_pack.all;

entity fwd is
	port (
	forwardA         : out fwd_type;
	forwardB         : out fwd_type;
	exec_rs : in std_logic_vector(REG_BITS-1 downto 0);
	exec_rt : in std_logic_vector(REG_BITS-1 downto 0);
	mem_rd : in std_logic_vector(REG_BITS-1 downto 0);
	wb_rd : in std_logic_vector(REG_BITS-1 downto 0)
);
	
end fwd;

architecture rtl of fwd is

begin  -- rtl

	supermux : process(exec_rs, exec_rt, mem_rd, wb_rd)
	begin
		forwardA <= FWD_NONE;
		forwardB <= FWD_NONE;

		if exec_rs = mem_rd and or_reduce(exec_rs) /= '0' then
			forwardA <= FWD_ALU;
		end if;
		if exec_rt = mem_rd and or_reduce(exec_rt) /= '0' then
			forwardB <= FWD_ALU;
		end if;

		if exec_rs = wb_rd and or_reduce(exec_rs) /= '0' then
			forwardA <= FWD_WB;
		end if;
		if exec_rt = wb_rd and or_reduce(exec_rt) /= '0' then
			forwardB <= FWD_WB;
		end if;
	end process;

end rtl;
