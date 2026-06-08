----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2026 11:10:33 AM
-- Design Name: 
-- Module Name: state_machine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity state_machine is
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           player1: in STD_LOGIC;
           player2: in STD_LOGIC;
           stop: in STD_LOGIC;
           led : out STD_LOGIC_vector(2 downto 0);
           state : out std_logic_vector(3 downto 0));
end state_machine;

architecture Behavioral of state_machine is
    signal current_state, next_state : STD_LOGIC_VECTOR(3 downto 0);
    signal current_led, next_led : STD_LOGIC_VECTOR(2 downto 0);
begin
clocking : process(clk, reset)
begin
    if (reset = '1') then            
        current_state <= "0000";
        current_led <= "000";    
    elsif (rising_edge(clk)) then
        if(stop = '0') then    
        current_state <= next_state;
        current_led <= next_led;
        end if;
    end if;
end process;
 
outputs : process(current_state, current_led,player1, player2)
begin
--    next_state <= current_state;
--    next_led <= current_led;
    if (current_state = "0000") then
        --state <= "0000";
        next_state <= "0001";
        next_led <= "000";
    elsif (current_state = "0001") then
        --state <= "0001";
        if (current_led = "110") then  
            next_state <= "0010";
            next_led <= "111";
        else
            next_state <= "0001";
            next_led <= current_led + 1;
        end if;      
    elsif (current_state = "0010") then
        --state <= "0010";  
        if(player2 = '1') then
            next_state <= "0011";    
            next_led <= current_led - 1;
        else
            next_state <= "0001";
            next_led <= "000";
        end if;
    elsif (current_state = "0011") then
        --state <= "0011";
        if (current_led = "001") then  
            next_state <= "0100";      
            next_led <= "000";
        else
            next_state <= "0011";
            next_led <= current_led - 1;
        end if;
    elsif (current_state = "0100") then
        if(player1 = '1') then  
             next_state <= "0001";    
             next_led <= current_led + 1;
        else
             next_state <= "0011";
             next_led <= "111";
        end if;
    else
        next_state <= "0000";
        next_led <= "000";
    end if;
end process;
state <= current_state;
led <= current_led;

end Behavioral;