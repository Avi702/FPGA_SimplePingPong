# FPGA Simple Ping Pong 🏓

A one-dimensional **Pong / "ping pong" game** built from scratch in **VHDL** and deployed to a **Digilent Arty S7-25 (Xilinx Spartan-7)** FPGA. The "ball" is a single lit LED that travels back and forth across a row of 8 LEDs. Each player has a button, and they have to hit it at the exact moment the ball reaches their end of the field — miss the timing and you lose the rally. Scores are tracked live on two seven-segment displays, and the first player to 10 wins the match with a flashing victory animation.

This was one of my first substantial digital-design projects, so the README below documents not just *what* it does but *what I learned* and *the hardest problems I had to solve* to get it working on real hardware.

---

## 🎮 How the game works

- **The field:** 8 LEDs in a row represent the playing field. Exactly one LED is lit at a time — that's the ball.
- **The bounce:** the ball moves one LED per game tick. When it reaches the far-right LED, Player 2 must press their button on that instant to return it; when it reaches the far-left LED, Player 1 must do the same.
- **Timing is everything:** the return only counts if the button is pressed while the ball is sitting on *your* end LED. Press too early or too late and the rally is over and your opponent scores.
- **Scoring:** each player's score is shown on its own seven-segment digit. First to **10** triggers a win state that flashes the LED bar, then the game resets.
- **Speed switch:** a slide switch picks between a slow (1 Hz) and fast (2 Hz) ball — easy mode vs. hard mode.
- **Reset button:** restarts the match at any time.

---

## 🛠️ Skills & concepts I learned

This project took me from "I can write a single combinational module" to building a complete, multi-module system that runs on physical hardware. Key things I picked up:

- **Structural VHDL / hierarchical design** — the top module ([pong_struct.vhd](pong_struct.vhd)) wires together ~10 sub-components (FSM, counter, clock dividers, multiplexers, display driver, input buffer) with named signals, instead of cramming everything into one file.
- **Finite State Machines (FSMs)** — the ball movement is a Moore-style FSM ([state_machine.vhd](state_machine.vhd)) with separate "next state" (combinational) and "register the state" (clocked) processes, which is the standard, synthesis-friendly way to write an FSM.
- **Clock division** — the 100 MHz board oscillator is *way* too fast to see, so I divide it down to 1 Hz / 2 Hz game clocks and a 60 Hz refresh clock ([clock_divider_1Hz.vhd](clock_divider_1Hz.vhd), [clock_divider_2Hz.vhd](clock_divider_2Hz.vhd), [clk60_div.vhd](clk60_div.vhd)).
- **Crossing clock domains carefully** — buttons are pressed in "human time" but have to be sampled by a slow game clock. Doing this naively drops or double-counts presses, which led to the main hurdle below.
- **Multiplexing a shared resource** — both seven-segment digits share the same `seg` lines, so a 60 Hz mux ([AuroraAvneet_21mux.vhd](AuroraAvneet_21mux.vhd) + [AuroraAvneet_mux1.vhd](AuroraAvneet_mux1.vhd)) rapidly alternates between Player 1's and Player 2's score and their anode-enable lines fast enough that both look continuously lit.
- **Seven-segment decoding** — a lookup that maps a 4-bit value to the right segment pattern ([AuroraAvneet_ssd.vhd](AuroraAvneet_ssd.vhd)).
- **FPGA pin constraints (XDC)** — mapping abstract port names to real physical pins, including using **PMOD headers** to get more I/O than the onboard peripherals provide (see below).
- **Synthesis vs. simulation reality** — behavior that looks fine in a testbench can still glitch on real silicon because of metastability, bounce, and timing. Debugging on hardware is a different skill from debugging in a simulator.

---

## 🚧 The big hurdle: making the button register only on the ball's edge instant

The hardest part of this project — and the thing I'm proudest of solving — was the **input buffer** ([input_buff.vhd](input_buff.vhd)).

**The problem:** A player can only score a return when the ball is on the rightmost or leftmost LED. But the game clock is slow (1–2 Hz), while a human button press lasts hundreds of milliseconds and is asynchronous to that clock. If I sampled the raw button directly on the game clock, two things broke:

1. A single press could get counted across multiple game ticks (one tap looked like "holding the paddle out"), so you'd never miss — the game was unloseable.
2. Or, depending on phase, a quick tap that didn't line up with the slow clock edge got dropped entirely, so legitimate returns were ignored.

In short, the rule "**the click has to land on the instant the ball is at your end LED**" wasn't being enforced.

**The fix:** I built a small buffer clocked on the *fast* 100 MHz clock that:

- **Latches** a button press the moment it happens (`p1Buf`/`p2Buf` get set high and held), so a fast human tap can't slip between the slow game ticks, and
- **Clears** those latched flags on the **rising edge of the game clock** — detected by delaying the game clock one fast-clock cycle (`game_clk_d`) and comparing it against the live value to find the edge.

So every game tick starts with a clean slate, the player's press is captured no matter when in the tick it lands, and it's only *consumed* by the FSM at the single game-clock edge where the ball is on the end LED. That's what makes the timing feel fair and deterministic: one press counts for exactly one rally attempt, evaluated at the right instant.

This was my first real encounter with **edge detection**, **synchronization across clock domains**, and why you can't just feed a raw, bouncy, asynchronous button straight into your logic — concepts that show up everywhere in digital design.

---

## 🔌 Using PMOD pins to get more LEDs and the displays

The Arty S7-25 only has 4 user LEDs onboard, but my field needs **8**. To get the rest of the I/O I needed, I broke out to the board's **PMOD headers** (configured in [Arty-S7-25-Master.xdc](Arty-S7-25-Master.xdc)):

- **LED bar (8 total):** the 4 onboard LEDs drive `board_leds[0..3]`, and **4 additional LEDs wired to the JB PMOD header** drive `board_leds[4..7]`, completing the 8-LED playing field.
- **Two seven-segment displays for score-keeping:** the 7 segment lines and the digit-enable (anode) lines are routed out over the **JC/JD PMOD headers**, with the 60 Hz mux switching between the two players' digits.

Learning to read the board's master constraints file and assign ports to specific package pins — and realizing the PMOD connectors were the way to expand beyond the onboard peripherals — was a practical hardware lesson that a pure-simulation project would never have taught me.

---

## 📁 Project structure

| File | Role |
| --- | --- |
| [pong_struct.vhd](pong_struct.vhd) | Top-level structural design — instantiates and wires everything together |
| [state_machine.vhd](state_machine.vhd) | FSM that moves the ball and detects valid returns |
| [counter.vhd](counter.vhd) | Score counter, win detection (first to 10), and win-flash timer |
| [input_buff.vhd](input_buff.vhd) | Button synchronizer / edge-gated input buffer (the key hurdle) |
| [led_array.vhd](led_array.vhd) | Decodes the 3-bit ball position into the 8 LED outputs |
| [clock_divider_1Hz.vhd](clock_divider_1Hz.vhd) / [clock_divider_2Hz.vhd](clock_divider_2Hz.vhd) | Slow game clocks (selectable ball speed) |
| [clk60_div.vhd](clk60_div.vhd) | 60 Hz clock for display multiplexing |
| [AuroraAvneet_ssd.vhd](AuroraAvneet_ssd.vhd) | Seven-segment display decoder |
| [AuroraAvneet_21mux.vhd](AuroraAvneet_21mux.vhd) / [AuroraAvneet_mux1.vhd](AuroraAvneet_mux1.vhd) | 4-bit and 1-bit 2:1 multiplexers (speed select + display sharing) |
| [Arty-S7-25-Master.xdc](Arty-S7-25-Master.xdc) | Pin constraints (buttons, switch, onboard + PMOD LEDs, displays) |
| [pong_struct.bit](pong_struct.bit) | Pre-built bitstream ready to flash to the board |

---

## 🚀 Building & running

1. Open the project in **Xilinx Vivado** and add all `.vhd` sources plus the `.xdc` constraints.
2. Set **`pong_struct`** as the top module.
3. Run **Synthesis → Implementation → Generate Bitstream** (or just program the included [pong_struct.bit](pong_struct.bit)).
4. Program the **Arty S7-25** over USB.
5. Wire 4 LEDs to the JB PMOD pins and the two seven-segment displays to the JC/JD PMOD pins per the constraints file.

**Controls:** `BTN0` = Player 1 return · `BTN2` = Player 2 return · `BTN1` = reset · `SW0` = ball speed (slow/fast).

---

## 🧰 Tech stack

**VHDL** · **Xilinx Vivado** · **Digilent Arty S7-25 (Spartan-7 FPGA)** · structural/RTL design · FSMs · clock-domain synchronization · PMOD I/O expansion.
