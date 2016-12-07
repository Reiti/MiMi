library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_memu is
end entity;

architecture beh of testbench_memu is
  signal op: mem_op_type;
  signal A: std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal W, D, R: std_logic_vector(DATA_WIDTH-1 downto 0);
  signal M: mem_out_type;
  signal XL, XS: std_logic;
begin

  mem: entity work.memu
  port map(
    op => op,
    A => A,
    W => W,
    D => D,
    M => M,
    R => R,
    XL => XL,
    XS => XS
  );

  test_memu: process is
  begin
    --tests for write
    op.memwrite <= '1';
    W <= x"89ABCDEF";

    --byte
    op.memtype <= MEM_B;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001";
    wait for 1 ns;
    A <= "100000000000000000010";
    wait for 1 ns;
    A <= "100000000000000000011";
    wait for 1 ns;
    --M.wrdata <= x"00000000";
    --halfword
    op.memtype <= MEM_H;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001"; --RAISES XS
    wait for 1 ns;
    A <= "100000000000000000010";
    wait for 1 ns;
    A <= "100000000000000000011"; --RAISES XS
    wait for 1 ns;

    --word
    op.memtype <= MEM_W;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001"; --RAISES XS
    wait for 1 ns;
    A <= "100000000000000000010"; --RAISES XS
    wait for 1 ns;
    A <= "100000000000000000011"; --RAISES XS
    wait for 1 ns;

    --tests for read
    op.memwrite <= '0';
    op.memread <= '1';
    D <= x"89ABCDEF";

    --byte
    op.memtype <= MEM_B;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001";
    wait for 1 ns;
    A <= "100000000000000000010";
    wait for 1 ns;
    A <= "100000000000000000011";
    wait for 1 ns;

    --unsigned byte
    op.memtype <= MEM_BU;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001";
    wait for 1 ns;
    A <= "100000000000000000010";
    wait for 1 ns;
    A <= "100000000000000000011";
    wait for 1 ns;

    --halfword
    op.memtype <= MEM_H;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001"; --RAISES XL
    wait for 1 ns;
    A <= "100000000000000000010";
    wait for 1 ns;
    A <= "100000000000000000011"; --RAISES XL
    wait for 1 ns;
    --unsigned halfword
    op.memtype <= MEM_HU;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001"; --RAISES XL
    wait for 1 ns;
    A <= "100000000000000000010";
    wait for 1 ns;
    A <= "100000000000000000011"; --RAISES XL
    wait for 1 ns;
    --word
    op.memtype <= MEM_W;
    A <= "100000000000000000000";
    wait for 1 ns;
    A <= "100000000000000000001"; --RAISES XL
    wait for 1 ns;
    A <= "100000000000000000010"; --RAISES XL
    wait for 1 ns;
    A <= "100000000000000000011"; --RAISES XL
    wait for 1 ns;

    --tests for zero address exception
    op.memread <= '0';
    op.memwrite <= '1';
    op.memtype <= MEM_BU;
    A <= "000000000000000000000"; --RAISES XS
    wait for 1 ns;
    A <= "100000000000000000000";
    wait for 1 ns;
    op.memwrite <= '0';
    op.memread <= '1';
    A <= "000000000000000000000"; -- RAISES XL
    wait for 1 ns;
  end process;

end architecture beh;
