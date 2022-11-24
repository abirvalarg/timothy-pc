library ieee;
use ieee.std_logic_1164.all;

library vcpu816;

entity vcpu816_tb is
	port(
		clk: in std_logic
	);
end;

architecture struct of vcpu816_tb is

component vcpu816 is
	port(
		clk, nrst, irq: in std_logic;
		din: in std_logic_vector(7 downto 0);
		write_mem: out std_logic;
		dout: out std_logic_vector(7 downto 0);
		addr: out std_logic_vector(15 downto 0)
	);
end component;

component rom0 is
	port(
		clka: in std_logic;
		addra: in std_logic_vector(10 downto 0);
		douta: out std_logic_vector(7 downto 0)
	);
end component;

signal write_mem: std_logic;
signal addr: std_logic_vector(15 downto 0);
signal dout, din: std_logic_vector(7 downto 0);

begin
	cpu: vcpu816 port map(
		clk => clk,
		nrst => '1',
		irq => '0',
		din => din,
		write_mem => write_mem,
		dout => dout,
		addr => addr
	);
	
	rom0_inst: rom0 port map(
		clka => clk,
		addra => addr(10 downto 0),
		douta => din
	);
end;
