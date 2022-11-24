library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		clk, nrst, irq, irq_en: in std_logic;
		data_bus: in std_logic_vector(7 downto 0);
		mux_sel: out integer range 0 to 5;
		alu_cmd: out integer range 0 to 10;
		reg_sel, tgt_sel: out integer range 0 to 3;
		rctl_cmd: out integer range 0 to 5;
		set_acc, set_alu_flags, set_offset, high_reg,
			use_offset, use_rel, set_addr, save_flags, set_res,
			write_mem, set_dis_irq, set_en_irq: out std_logic;
		bus_output: out std_logic_vector(7 downto 0)
	);
end;

architecture struct of control_unit is

signal instr: std_logic_vector(7 downto 0);
signal cycle: integer range 0 to 15 := 0;
signal init: std_logic := '1';
signal skip, write_instr, irq_mode, end_init,
	end_irq: std_logic := '0';

begin
	upd_p: process(nrst, clk)
	begin
		if nrst = '0' then
			cycle <= 0;
			init <= '1';
			irq_mode <= '0';
		elsif clk'event and clk = '0' then
			if cycle = 15 then
				cycle <= 0;
			else
				cycle <= cycle + 1;
			end if;
			-- end_irq <= '1' when irq_mode = '1' and cycle = 12 else '0';
			if cycle = 0 and irq_en = '1' and irq = '1' and irq_mode = '0' then
				irq_mode <= '1';
			elsif irq_mode = '1' and cycle = 13 then
				irq_mode <= '0';
				cycle <= 0;
			end if;
		elsif clk'event and clk = '1' then
			if skip = '1' then
				cycle <= 15;
			end if;
			if end_init = '1' then
				init <= '0';
			end if;
			if write_instr = '1' then
				instr <= data_bus;
			end if;
		end if;
	end process;
	
	write_instr <= '1' when init = '0' and irq_mode = '0' and cycle = 2 else '0';
	
	set_acc <= '1' when
		(init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 5)		-- LDI
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 8)	-- LDA imm16
		else '0';
	
	set_alu_flags <= '0';
	
	set_offset <= '1' when
		(init = '1' and cycle = 1)
		or (init = '1' and cycle = 5)
		or (irq_mode = '1' and cycle = 6)
		or (irq_mode = '1' and cycle = 9)
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 4)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 6)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 5)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 8)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 5)	-- JMP imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 8)	-- JMP imm16
		else '0';
	
	high_reg <= '1' when
		(init = '1' and cycle = 8)
		or (irq_mode = '1' and cycle = 2)
		or (irq_mode = '1' and cycle = 11)
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 6)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 8)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 8)	-- JMP imm16
		else '0';
	
	use_offset <= '1' when
		(init = '1' and cycle = 2)
		or (init = '1' and cycle = 6)
		or (irq_mode = '1' and cycle = 7)
		or (irq_mode = '1' and cycle = 10)
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 7)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 9)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 9)	-- JMP imm16
		else '0';
	
	use_rel <= '1' when
		(init = '0' and irq_mode = '0' and cycle = 0)
		or (init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 3)	-- LDI
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 3)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 5)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 3)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 6)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 3)	-- JMP imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 6)	-- JMP imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 9)	-- JMP imm16
		else '0';
	
	set_addr <= '1' when
		(init = '1' and cycle = 2)
		or (init = '1' and cycle = 6)
		or (irq_mode = '1' and cycle = 1)
		or (irq_mode = '1' and cycle = 4)
		or (irq_mode = '1' and cycle = 7)
		or (irq_mode = '1' and cycle = 10)
		or (init = '0' and irq_mode = '0' and cycle = 0)
		or (init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 3)	-- LDI
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 3)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 5)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 7)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 3)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 6)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 9)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 3)	-- JMP imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 6)	-- JMP imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 9)	-- JMP imm16
		else '0';
	
	save_flags <= '0';
	
	write_mem <= '1' when
		(irq_mode = '1' and cycle = 2)
		or (irq_mode = '1' and cycle = 5)
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 10)	-- STA imm16
		else '0';
	
	skip <= '1' when
		(init = '1' and cycle = 9)
		or (irq_mode = '1' and cycle = 12)
		or (init = '0' and irq_mode = '0' and instr = "00000000" and cycle = 3)	-- NOP
		or (init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 5)	-- LDI
		or (init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 8)	-- LDA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 11)	-- STA imm16
		or (init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 11)	-- JMP
		else '0';
	
	end_init <= '1' when init = '1' and cycle = 9 else '0';
	
	mux_sel <=
		0 when init = '1' and cycle = 1 else
		1 when init = '1' and cycle = 4 else
		0 when init = '1' and cycle = 5 else
		1 when init = '1' and cycle = 8 else
		5 when irq_mode = '1' and cycle = 2 else
		5 when irq_mode = '1' and cycle = 5 else
		0 when irq_mode = '1' and cycle = 6 else
		1 when irq_mode = '1' and cycle = 8 else
		0 when irq_mode = '1' and cycle = 9 else
		1 when irq_mode = '1' and cycle = 11 else
		1 when init = '0' and irq_mode = '0' and cycle = 2 else
		1 when init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 5 else	-- LDI
		1 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 4 else	-- LDA imm16
		1 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 6 else	-- LDA imm16
		1 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 8 else	-- LDA imm16
		1 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 5 else	-- STA imm16
		1 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 8 else	-- STA imm16
		2 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 10 else	-- STA imm16
		1 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 5 else	-- JMP
		1 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 8 else	-- JMP
		0;
	
	alu_cmd <= 0;
	
	reg_sel <=
		3 when init = '1' and cycle = 4 else
		3 when init = '1' and cycle = 8 else
		2 when irq_mode = '1' and cycle = 0 else
		2 when irq_mode = '1' and cycle = 1 else
		3 when irq_mode = '1' and cycle = 2 else
		2 when irq_mode = '1' and cycle = 3 else
		2 when irq_mode = '1' and cycle = 4 else
		3 when irq_mode = '1' and cycle = 5 else
		3 when irq_mode = '1' and cycle = 8 else
		3 when irq_mode = '1' and cycle = 11 else
		3 when init = '0' and irq_mode = '0' and cycle = 0 else
		3 when init = '0' and irq_mode = '0' and cycle = 1 else
		3 when init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 3 else	-- LDI
		3 when init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 4 else	-- LDI
		3 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 3 else	-- LDA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 4 else	-- LDA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 5 else	-- LDA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 6 else	-- LDA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 3 else	-- STA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 4 else	-- STA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 6 else	-- STA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 7 else	-- STA imm16
		3 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 3 else	-- JMP
		3 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 4 else	-- JMP
		3 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 6 else	-- JMP
		3 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 8 else	-- JMP
		3 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 9 else	-- JMP
		3 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 10 else	-- JMP
		0;
	
	rctl_cmd <=
		1 when init = '1' and cycle = 4 else
		1 when init = '1' and cycle = 8 else
		3 when irq_mode = '1' and cycle = 0 else
		3 when irq_mode = '1' and cycle = 3 else
		1 when irq_mode = '1' and cycle = 8 else
		1 when irq_mode = '1' and cycle = 11 else
		2 when init = '0' and irq_mode = '0' and cycle = 1 else
		2 when init = '0' and irq_mode = '0' and instr = "00000001" and cycle = 4 else	-- LDI
		2 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 4 else	-- LDA imm16
		2 when init = '0' and irq_mode = '0' and instr = "00000010" and cycle = 6 else	-- LDA imm16
		2 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 4 else	-- STA imm16
		2 when init = '0' and irq_mode = '0' and instr = "00000011" and cycle = 7 else	-- STA imm16
		2 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 4 else	-- JMP
		2 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 8 else	-- JMP
		5 when init = '0' and irq_mode = '0' and instr = "00000100" and cycle = 10 else	-- JMP
		0;

	bus_output <=
		"00000000" when init = '1' and cycle = 1 else
		"00000001" when init = '1' and cycle = 5 else
		"00000010" when irq_mode = '1' and cycle = 6 else
		"00000011" when irq_mode = '1' and cycle = 9 else
		"00000000";
end;
