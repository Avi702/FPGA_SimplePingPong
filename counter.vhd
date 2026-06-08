library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
    Port ( clk : in std_logic;
           reset : in std_logic;
           state : in std_logic_vector(3 downto 0);
           output1 : out std_logic_vector(3 downto 0);
           output2 : out std_logic_vector(3 downto 0);
           p1_won : out std_logic;
           p2_won : out std_logic);
end counter;

architecture Behavioral of counter is
    signal player1 : std_logic_vector(3 downto 0) := "0000";
    signal player2 : std_logic_vector(3 downto 0) := "0000";
    signal prev_state : std_logic_vector(3 downto 0) := "0000";
    signal p1_winner_reg : std_logic := '0';
    signal p2_winner_reg : std_logic := '0';
    signal flash_timer : std_logic_vector(2 downto 0) := "000";
begin

process(clk, reset)
begin
    if (reset = '1') then
        player1 <= "0000";
        player2 <= "0000";
        prev_state <= "0000";
        p1_winner_reg <= '0';
        p2_winner_reg <= '0';
        flash_timer <= "000";
    elsif (rising_edge(clk)) then
        prev_state <= state;
        if (p1_winner_reg = '1' or p2_winner_reg = '1') then
            if (flash_timer = "100") then
                p1_winner_reg <= '0';
                p2_winner_reg <= '0';
                flash_timer  <= "000";
            else
                flash_timer <= flash_timer + 1;
            end if;
        else
            if (prev_state = "0010" and state = "0001") then
                if (player1 = "1001") then
                    player1 <= "0000";
                    player2 <= "0000";
                    p1_winner_reg <= '1';
                else
                    player1 <= player1 + 1;
                end if;
            end if;
            if (prev_state = "0100" and state = "0011") then
                if (player2 = "1001") then
                    player2 <= "0000";
                    player1 <= "0000";
                    p2_winner_reg <= '1';
                else
                    player2 <= player2 + 1;
                end if;
            end if;
        end if;
    end if;
end process;
output1 <= player1;
output2 <= player2;
p1_won <= p1_winner_reg;
p2_won <= p2_winner_reg;

end Behavioral;