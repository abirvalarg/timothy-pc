library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
	port(
		a, b: in std_logic;
		res, carry: out std_logic
	);
end;

architecture struct of half_adder is
begin
	res <= a xor b;
	carry <= a and b;
end;
