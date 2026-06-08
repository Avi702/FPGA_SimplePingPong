----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2026 05:50:26 PM
-- Design Name: 
-- Module Name: AuroraAvneet_mux1 - Behavioral
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

entity AuroraAvneet_mux1 is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           S : in STD_LOGIC;
           Y : out STD_LOGIC);
end AuroraAvneet_mux1;

architecture Behavioral of AuroraAvneet_mux1 is

begin
Y <= A when (S = '0') else B;
end Behavioral;
