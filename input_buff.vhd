library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity input_buff is
    Port ( clk         : in  STD_LOGIC;
           game_clk_in : in  STD_LOGIC;
           p1          : in  STD_LOGIC;
           p2          : in  STD_LOGIC;
           reset_in    : in  STD_LOGIC;
           p1Buf       : out STD_LOGIC;
           p2Buf       : out STD_LOGIC;
           reset_out   : out STD_LOGIC);
end input_buff;

architecture Behavioral of input_buff is
    signal game_clk_d  : STD_LOGIC := '0';
begin

clocking : process(clk)
begin
    if (rising_edge(clk)) then
        game_clk_d <= game_clk_in;
        if ((game_clk_d /= game_clk_in)  and game_clk_in = '1') then
            p1Buf <= '0';
            p2Buf <= '0';
            reset_out <= '0';
        elsif (p1 = '1') then
            p1Buf <= '1';
        elsif (p2 = '1') then
            p2Buf <= '1';        
        elsif (reset_in = '1') then
            reset_out <= '1';
    end if;
    end if;
end process;
end Behavioral;