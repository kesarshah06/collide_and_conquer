#  CollideAndConquer

This repository contains the Verilog implementation of the **Rival Car module** for a VGA-based racing game.
It forms **Part 3 of Lab Assignment 8** for **COL215: Digital Logic & System Design** under the **Department of Computer Science & Engineering, IIT Delhi**.

The design features pseudo-random car spawning using an LFSR, ROM-based sprite display, collision detection, VGA timing generation, and full hardware testing on the Basys3 FPGA board.

---

##  Repository Structure

```
 vga-rival-car
 ┣ VGA_driver.v
 ┣ Horiz_counter.v
 ┣ Vert_counter.v
 ┣ Display_sprite-2.v
 ┣ bg_motion.v
 ┣ rival_car_fsm.v
 ┣ car_fsm-2.v
 ┣ random.v
 ┣ debouncer.v
 ┣ tb_8.v
 ┣ tb_rival.v
 ┣ basys3-4.xdc
 ┣ Lab_Report_8_3.pdf
 ┗ rom/
     ┣ rival_car_rom.v
     ┣ main_car_rom.v
     ┗ bg_rom.v
```

---

##  Assignment Objective

From the Lab 8 P3 PDF :

The goal is to design and integrate a **Rival Car subsystem** into an existing VGA racing game, including:

* An **8-bit pseudo-random number generator (LFSR)** for spawn locations
* A **single-port ROM** (`rival_car_rom`) storing the rival car sprite
* Logic to generate:

  * `rival_x` = random value between **44 and 104 pixels**
  * `rival_y` = fixed offset at top of screen
* A **frame-based movement system** for smooth vertical motion
* **Collision detection** between main car and rival car
* Automatic **respawn** after collision or reaching screen bottom
* Complete **simulation & hardware verification**

---

## Features

### ✔ 1. VGA Display Pipeline

Using the modules described in the report (page 4) :

* Horizontal counter
* Vertical counter
* Sync signals (HS, VS)
* Pixel enable
* Sprite compositing
* Final 12-bit RGB output

### ✔ 2. Pseudo-Random Generator (LFSR)

* 8-bit maximal sequence generator
* Polynomial:

  ```
  new_bit = q[7] XOR q[5] XOR q[4] XOR q[3]
  ```
* Generates random X spawn positions
* Seed based on Kerberos IDs (page 5) .

### ✔ 3. Rival Car FSM

Handles:

* Spawn
* Movement
* Collision detection
* Respawn
* Synchronization with main car positions

### ✔ 4. Collision Logic

Bounding box overlap detection as shown with simulation snapshots (pages 6–8) .

### ✔ 5. Testbenches

Two testbenches provided:

| TB File      | Purpose                          |
| ------------ | -------------------------------- |
| `tb_8.v`     | Simulates collision & respawn    |
| `tb_rival.v` | Shows random X spawning via LFSR |

---

##  Running the Testbench

Using Icarus Verilog:

### **Testbench 1 (Collision)**

```sh
iverilog -o tb_8 tb_8.v VGA_driver.v Display_sprite-2.v rival_car_fsm.v random.v ...
vvp tb_8
```

### **Testbench 2 (Random spawn)**

```sh
iverilog -o tb_rival tb_rival.v random.v rival_car_fsm.v
vvp tb_rival
```

(Include ROMs & counters during compilation depending on your simulation setup.)

---

##  FPGA Deployment (Basys3)

1. Open **Vivado** → Create project
2. Add:

   * All Verilog files
   * `basys3-4.xdc` (pin mapping)
3. Run:

   * Synthesis
   * Implementation
   * Bitstream generation
4. Program FPGA through Hardware Manager

### VGA Pin Mapping

As given on page 14 of the report :

* RGB signals: `vgaRGB[11:0]` → Pins G19…J18
* `HS` → P19
* `VS` → R19
* `clk` → W5

---

##  Simulation & Hardware Results

The PDF includes:

* Collision detection waveforms (pages 6–7)
* Random LFSR output waveforms (page 8)
* Respawn logic (page 8–9)
* VGA output images showing correct sprite rendering (pages 11–13)

All these behaviours match the expected design requirements.

---

##  Conclusion

The Rival Car subsystem was successfully integrated with the VGA game, demonstrating:

* Correct pseudo-random spawning
* Smooth movement
* Accurate collision detection
* Proper VGA rendering
* Successful FPGA implementation

