library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity clk60Hz is
    Port ( clk_in  : in STD_LOGIC;
           reset   : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end clk60Hz;

architecture Behavioral of clk60Hz is
    signal temporal : STD_LOGIC := '0';
    signal counter  : integer range 0 to 833332 := 0;
begin

    frequency_divider: process (reset, clk_in) 
    begin
        if (reset = '1') then
            temporal <= '0';
            counter <= 0;
        elsif rising_edge(clk_in) then
            if (counter = 833332) then
                temporal <= NOT(temporal); 
                counter <= 0;             
            else
                counter <= counter + 1;    
            end if;
        end if;
    end process;
    clk_out <= temporal;

end Behavioral;
