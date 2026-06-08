----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2026 12:52:44 PM
-- Design Name: 
-- Module Name: pong_struct - Structural
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

entity pong_struct is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           p1 : in  STD_LOGIC;
           p2 : in  STD_LOGIC;
           speed_switch : in STD_LOGIC;
           board_leds : out STD_LOGIC_VECTOR(7 downto 0);
           seg : out STD_LOGIC_VECTOR(6 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0));
end pong_struct;
 
architecture Structural of pong_struct is
component counter is
    Port(clk: in std_logic;
         reset: in std_logic;
         state: in std_logic_vector(3 downto 0);
         output1: out std_logic_vector(3 downto 0);
         output2: out std_logic_vector(3 downto 0);
         p1_won: out std_logic;
         p2_won: out std_logic);
end component ; 
component state_machine is
        Port ( reset : in  STD_LOGIC;
               clk : in  STD_LOGIC;
               player1 : in  STD_LOGIC;
               player2 : in  STD_LOGIC;
               stop: in STD_LOGIC;
               led : out STD_LOGIC_VECTOR(2 downto 0);
               state : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    component leds is
        Port ( led_array : in  STD_LOGIC_VECTOR(2 downto 0);
               led : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    component clk1Hz is
        Port ( clk_in : in  STD_LOGIC;
               reset : in STD_LOGIC;
               clk_out : out STD_LOGIC);
    end component;
    component clk2Hz is
        Port ( clk_in: in STD_LOGIC;
               reset : in STD_LOGIC;
               clk_out : out STD_LOGIC);
    end component;
    component clk60Hz is
        Port ( clk_in : in STD_LOGIC;
               reset : in STD_LOGIC;
               clk_out : out STD_LOGIC);
    end component;
    component AuroraAvneet_ssd is
        Port ( sw : in STD_LOGIC_VECTOR(3 downto 0);
               seg : out STD_LOGIC_VECTOR(6 downto 0);
               cat : out STD_LOGIC);
    end component;
    component AuroraAvneet_21mux is
        Port ( A : in STD_LOGIC_VECTOR(3 downto 0);
               B : in STD_LOGIC_VECTOR(3 downto 0);
               S : in STD_LOGIC;
               Y : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    component AuroraAvneet_mux1 is
        Port ( A : in STD_LOGIC;
               B : in STD_LOGIC;
               S : in STD_LOGIC;
               Y : out STD_LOGIC);
    end component;
    component input_buff is
    Port ( clk : in STD_LOGIC;
           game_clk_in : in STD_LOGIC;
           p1 : in STD_LOGIC;
           p2 : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           p1Buf : out STD_LOGIC;
           p2Buf : out STD_LOGIC;
           reset_out : out STD_LOGIC);
end component;
signal wire_1Hz : STD_LOGIC;
signal wire_2Hz : STD_LOGIC;
signal wire_60Hz : STD_LOGIC;
signal game_clk : STD_LOGIC;
signal wire_ball_pos : STD_LOGIC_VECTOR(2 downto 0);
signal wire_fsm_state : STD_LOGIC_VECTOR(3 downto 0);
signal wire_cat : STD_LOGIC;
signal wire_ssd_in : STD_LOGIC_VECTOR(3 downto 0);
signal wire_p1_score: std_logic_vector(3 downto 0);
signal wire_p2_score: std_logic_vector(3 downto 0);
signal wire_p1Buf : STD_LOGIC;
signal wire_p2Buf : STD_LOGIC;
signal wire_reset_buf : STD_LOGIC;
signal wire_p1_won : STD_LOGIC;
signal wire_p2_won : STD_LOGIC;
signal ball_leds: STD_LOGIC_VECTOR(7 downto 0);
signal wire_stop: std_logic;
begin
c1 : clk1Hz  port map(clk_in => clk, reset => reset, clk_out => wire_1Hz);
c2 : clk2Hz  port map(clk_in => clk, reset => reset, clk_out => wire_2Hz);
c3 : clk60Hz port map(clk_in => clk, reset => reset, clk_out => wire_60Hz);
speed_mux : AuroraAvneet_mux1 port map(A => wire_1Hz,B => wire_2Hz,
        S => speed_switch,
        Y => game_clk
    );
wire_stop <= wire_p1_won or wire_p2_won;
buf : input_buff port map(
    clk => clk,
    game_clk_in => game_clk,
    p1 => p1,
    p2 => p2,
    reset_in => reset,
    p1Buf => wire_p1Buf,
    p2Buf => wire_p2Buf,
    reset_out => wire_reset_buf
);
fsm : state_machine port map(
        reset => wire_reset_buf,
        clk => game_clk,
        player1 => wire_p1Buf,
        player2 => wire_p2Buf,
        stop => wire_stop,
        led => wire_ball_pos,
        state => wire_fsm_state
    );
count: counter port map(
       clk => game_clk,
       reset => wire_reset_buf,
       state => wire_fsm_state,
       output1 => wire_p1_score,
       output2 => wire_p2_score,
       p1_won=> wire_p1_won,
       p2_won=> wire_p2_won);
lights : leds port map(
        led_array => wire_ball_pos,
        led => ball_leds
    );
board_leds <= "00001111" when (wire_p1_won = '1' and game_clk = '1') else
                  "11110000" when (wire_p2_won = '1' and game_clk = '1') else
                  "00000000" when ((wire_p1_won = '1' or wire_p2_won = '1') and game_clk = '0') else
                  ball_leds;
    mux_data : AuroraAvneet_21mux port map(
        A => wire_p1_score,
        B => wire_p2_score,
        S => wire_60Hz,
        Y => wire_ssd_in
    );
    
    ssd : AuroraAvneet_ssd port map(
        sw => wire_ssd_in,
        seg => seg,
        cat => wire_cat
    );
 mux_an : AuroraAvneet_21mux port map(
        A => "1110",
        B => "1101",
        S => wire_60Hz,
        Y => an
    );
 
end Structural;