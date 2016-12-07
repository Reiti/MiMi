library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_jmpu is
end entity;

architecture beh of testbench_jmpu is
  signal op: jmp_op_type;
  signal N, Z, J: std_logic;
begin
  jmp: entity work.jmpu
  port map(
    op => op,
    N => N,
    Z => Z,
    J => J
  );

  jmpu_test: process
  begin
    op <= JMP_NOP;
    N <= '0';
    Z <= '0';
    wait for 1 ns;
    op <= JMP_JMP;
    wait for 1 ns;

    op <= JMP_BEQ;
    Z <= '1';
    wait for 1 ns;

    op <= JMP_BNE;
    Z <= '1';
    wait for 1 ns;

    op <= JMP_BLEZ;
    N <= '1';
    Z <= '0';
    wait for 1 ns;
    N <= '0';
    wait for 1 ns;
    Z <= '1';
    wait for 1 ns;

    op <= JMP_BGTZ;
    N <= '1';
    Z <= '0';
    wait for 1 ns;
    N <= '0';
    wait for 1 ns;
    Z <= '1';
    wait for 1 ns;

    op <= JMP_BLTZ;
    Z <= '0';
    N <= '1';
    wait for 1 ns;
    N <= '0';
    wait for 1 ns;

    op <= JMP_BGEZ;
    N <= '1';
    wait for 1 ns;
    N <= '0';
    wait for 1 ns;
  end process;
end architecture beh;
