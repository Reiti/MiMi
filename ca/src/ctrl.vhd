library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
	
	port (
		J : in std_logic;
		flush : out std_logic 
);

end ctrl;

architecture rtl of ctrl is

begin  -- rtl

	pro: process(J) is
	begin 
		flush <= J;
	end process;


end rtl;
