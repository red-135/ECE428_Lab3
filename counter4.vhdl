library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter4 is
    port
	(
		clk : in STD_LOGIC;
		enable : in STD_LOGIC;
		reset : in STD_LOGIC;
		output : out STD_LOGIC_VECTOR (3 downto 0)
	);
end counter4;

architecture behavioral of counter4 is
	signal cnt : std_logic_vector (3 downto 0);
begin
	output <= cnt;
	
	process (clk, enable, reset)
	begin
		if (reset = '1') then
			cnt <= "0000";
		else
			if (rising_edge(clk)) then
				if (enable = '1') then
					cnt <= std_logic_vector(unsigned(cnt) + 1);
				end if;
			end if;
		end if;
	end process;
end behavioral;