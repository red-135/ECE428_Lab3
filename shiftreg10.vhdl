library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shiftreg10 is
    port
	(
		clk : in STD_LOGIC;
		shen : in STD_LOGIC;
		lden : in STD_LOGIC;
		ldval : in STD_LOGIC_VECTOR (9 downto 0);
		shout : out STD_LOGIC
	);
end shiftreg10;

architecture behavioral of shiftreg10 is
	signal reg : std_logic_vector (9 downto 0);
	
	attribute keep : string;
	attribute keep of reg : signal is "true";	
begin
	shout <= reg(0);
	
	process (clk, ldval, lden, shen)
	begin
		if (lden = '1') then
			reg <= ldval;
		else
			if (rising_edge(clk)) then
				if (shen = '1') then
					reg(8 downto 0) <= reg(9 downto 1);
					reg(9)          <= '0';
				end if;
			end if;
		end if;
	end process;
end behavioral;