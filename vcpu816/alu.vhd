library ieee;
use ieee.std_logic_1164.all;

entity alu is
	port(
		cmd: in integer range 0 to 9;
		a, b: in std_logic_vector(7 downto 0);
		carry_in: in std_logic;
		result: out std_logic_vector(7 downto 0);
		sign, carry_out, zero: out std_logic
	);
end;

architecture struct of alu is

component half_adder is
	port(
		a, b: in std_logic;
		res, carry: out std_logic
	);
end component;

signal tmp_res, add_res, tmp, c1, c2, carry: std_logic_vector(7 downto 0);
signal use_carry, use_adder, sub: std_logic;

begin
	adder: for i in 0 to 7 generate
		half1: half_adder port map(
			a => a(i),
			b => b(i) xor sub,
			res => tmp(i),
			carry => c1(i)
		);

		half2_0: if i = 0 generate
			half2: half_adder port map(
				a => tmp(i),
				b => (carry_in and use_carry) xor sub,
				res => add_res(i),
				carry => c2(i)
			);
		end generate;
		
		half2_i: if i > 0 generate
			half2: half_adder port map(
				a => tmp(i),
				b => c1(i - 1) or c2(i - 1),
				res => add_res(i),
				carry => c2(i)
			);
		end generate;
	end generate;
	
	with cmd select tmp_res <=
		add_res when 0 | 1 | 2 | 3,
		not a when 4,
		a or b when 5,
		a and b when 6,
		a xor b when 7,
		a(6 downto 0) & "0" when 8,	-- shift left
		"0" & a(7 downto 1) when 9,	-- shift right
		"00000000" when others;
	
	with cmd select use_carry <=
		'1' when 1 | 3,
		'0' when others;
		
	with cmd select sub <=
		'1' when 2 | 3,
		'0' when others;
	
	sign <= tmp_res(7);
	with cmd select carry_out <=
		(c1(7) or c2(7)) xor sub when 0 | 1 | 2 | 3,
		a(7) when 8,
		a(0) when 9,
		'0' when others;
	zero <= '1' when tmp_res = "00000000" else '0';
	
	result <= tmp_res;
end;
