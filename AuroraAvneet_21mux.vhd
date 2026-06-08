----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2026 03:57:14 PM
-- Design Name: 
-- Module Name: AuroraAvneet_21mux - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AuroraAvneet_21mux is
    Port ( A : in std_logic_vector(3 downto 0);
           B : in std_logic_vector(3 downto 0);
           S : in STD_LOGIC;
           Y : out std_logic_vector(3 downto 0));
end AuroraAvneet_21mux;

architecture Behavioral of AuroraAvneet_21mux is

begin

Y <= A when (S = '0') else B;
end Behavioral;
