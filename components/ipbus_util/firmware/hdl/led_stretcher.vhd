-- stretcher
--
-- Stretches a single clock pulse so it's visible on an LED
--
-- Dave Newbold, January 2013
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_stretcher is
	generic(
		WIDTH: positive := 1
	);
	port(
		clk: in std_logic; -- Assumed to be 125MHz ipbus clock
		d: in std_logic_vector(WIDTH - 1 downto 0); -- Input (edge detected)
		q: out std_logic_vector(WIDTH - 1 downto 0) -- LED output, ~250ms pulse
	);

end led_stretcher;

architecture rtl of led_stretcher is

	signal d17, d17_d: std_logic;
	
begin
	
	clkdiv: entity work.ipbus_clock_div
		port map(
			clk => clk,
			d17 => d17
		);

	process(clk)
	begin
		if rising_edge(clk) then
			d17_d <= d17;
		end if;
	end process;
	
	lgen: for i in WIDTH - 1 downto 0 generate
	
		signal s, sd, e, e_d, sl: std_logic;
		signal scnt: unsigned(6 downto 0);
	
	begin
	
		process(clk)
		begin
			if rising_edge(clk) then
				s <= d(i); -- Possible clock domain crossing from slower clock (sync not important)
				sd <= s;
				e <= (e or (s and not sd)) and not e_d;
				if d17 = '1' and d17_d = '0' then
					e_d <= sl;
					if e = '1' then
						scnt <= "0000001";
					elsif sl = '0' then
						scnt <= scnt + 1;
					end if;					
				end if;
			end if;
		end process;

		sl <= '1' when scnt = "0000000" else '0';
		
		q(i) <= not sl;
		
	end generate;
	
end rtl;
