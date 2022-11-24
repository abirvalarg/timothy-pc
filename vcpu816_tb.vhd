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

component ndisp is
	port(
		inter_clk, io_clk, wr, nrst: in std_logic;
		addr: in std_logic_vector(2 downto 0);
		data_bus: in std_logic_vector(7 downto 0);
		segments: out std_logic_vector(1 to 7);
		dp: out std_logic;
		digit_sel: out std_logic_vector(0 to 7)
	);
end component;

signal write_mem: std_logic;
signal addr: std_logic_vector(15 downto 0);
signal dout, din: std_logic_vector(7 downto 0);
signal seg: std_logic_vector(1 to 7);
signal dp: std_logic;
signal ds: std_logic_vector(0 to 7);

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
	
	ndisp_inst: ndisp port map(
		inter_clk => clk,
		io_clk => clk,
		wr => write_mem,
		nrst => '1',
		addr => addr(2 downto 0),
		data_bus => dout,
		segments => seg,
		dp => dp,
		digit_sel => ds
	);
	
	rom0_inst: rom0 port map(
		clka => clk,
		addra => addr(10 downto 0),
		douta => din
	);
end;
