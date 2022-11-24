library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu_psc is
	port(
		clk_in: in std_logic;
		clk_out: out std_logic
	);
end;

architecture struct of cpu_psc is

signal counter: std_logic_vector(1 downto 0) := "00";

begin
	upd_p: process(clk_in)
	begin
		if clk_in'event and clk_in = '1' then
			counter <= counter + "01";
		end if;
	end process;
	
	clk_out <= counter(1);
end;
