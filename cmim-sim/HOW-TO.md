# CMIM — Cascaded Modulator Ising Machine
## How-To Manual: Simulation & Z80/MINT Driver

---

## What This Is

An **Ising machine** is a physical system that solves hard optimization problems by
letting physics find the lowest-energy configuration instead of calculating every
possibility digitally. The **Cascaded Modulator Ising Machine (CMIM)** is a photonic
research implementation of this idea — but the underlying math maps directly onto a
bench-top op-amp circuit controllable from a Z80/TEC-1 running MINT.

This folder contains two implementations:

| File | Purpose |
|---|---|
| `ising_sim.m` | Full software simulation (Octave) with real-time graphing + optional GPIO |
| `ising.mint` | MINT2 driver for a physical TEC-1/Z80 Ising coprocessor board |

---

## Part 1 — Octave Simulation (`ising_sim.m`)

### What it simulates

Each spin node models an analog op-amp integrator + tanh nonlinearity:

```
tau * du/dt = -u + J·tanh(gain·u) + h + noise
```

- `u`    = integrator voltage state
- `J`    = coupling matrix (the problem to solve)
- `h`    = bias vector
- `gain` = tanh steepness (inverse temperature)
- `noise`= injected noise, annealed down over time

Spins are read as `s = tanh(gain * u)`, binarised to `sign(s)` for the solution.

### Requirements

- GNU Octave (any recent version)
- A display (X11/Wayland) for the live plot window
- Optional: Linux GPIO (Raspberry Pi or similar) for hardware output

### Running it

```bash
cd cmim-sim
octave ising_sim.m
```

The simulation window opens immediately. Use keyboard commands to control it:

| Key | Action |
|---|---|
| `s` | Solve — reset state, run 3000 steps, settle to solution |
| `p` | Load Max-Cut problem (fully connected antiferromagnetic) |
| `x` | Load ring graph problem (nearest-neighbour) |
| `r` | Load random sparse problem |
| `n` | Toggle noise annealing on/off |
| `+` | Increase noise amplitude × 1.5 |
| `-` | Decrease noise amplitude × 0.67 |
| `g` | Toggle GPIO output (requires `use_gpio = true`, see below) |
| `q` | Quit |

### The four plot panels

```
+--------------------+--------------------+
|  Spin States       |  Coupling Matrix J |
|  (bar chart,       |  (heatmap, red=    |
|   green=+1 red=-1) |   ferro blue=anti) |
+--------------------+--------------------+
|  Energy vs Time    |  Phase Space       |
|  (should drop and  |  (u_i vs tanh(u_i) |
|   plateau)         |   shows dynamics)  |
+--------------------+--------------------+
```

**Energy dropping and levelling off** is the sign of a good solve. If it stays noisy,
increase the annealing rate or reduce noise.

### Key parameters (edit top of file)

```octave
N          = 8;       % number of spins (nodes)
dt         = 0.001;   % time step (seconds)
tau        = 0.010;   % integrator RC constant
gain       = 5.0;     % tanh steepness / inverse temperature
noise_amp  = 0.3;     % starting noise level
anneal     = true;    % ramp noise down over time
anneal_rate= 0.995;   % noise × this each step (0.99=fast, 0.9999=slow)
n_steps    = 3000;    % steps per solve run
use_gpio   = false;   % set true for hardware GPIO output
```

Tuning tips:

- **Stuck in local minima?** — raise `noise_amp` or lower `anneal_rate`
- **Noisy, never settles?** — raise `anneal_rate` closer to 1.0, or lower `noise_amp`
- **Too slow?** — reduce `n_steps`, or increase `dt` (at cost of accuracy)
- **Larger problem?** — increase `N` (8→16 works fine; 64+ gets slow without changes)

### Enabling GPIO output

Set `use_gpio = true` at the top of the file. The simulation maps each spin's final
binary state (+1 or −1) to GPIO pins 17–24 (BCM numbering, suitable for Raspberry Pi).

```
Spin 1 → GPIO 17
Spin 2 → GPIO 18
...
Spin 8 → GPIO 24
```

Output is written via Linux sysfs (`/sys/class/gpio/`). Requires write permission:

```bash
sudo octave ising_sim.m
# OR add your user to the gpio group
```

Pin logic: `+1 spin → HIGH`, `−1 spin → LOW`.

Use these outputs to drive LEDs, relay drivers, or feed back to analog hardware.

---

## Part 2 — Physical Hardware Build

This section is a complete build guide. Start with a single 4-node prototype on
protoboard, verify it works, then scale up.

---

### 2.1 Bill of Materials

#### 4-node prototype (cheapest, build first)

| Part | Value / Part# | Qty | Notes |
|---|---|---|---|
| TL084 quad op-amp | DIP-14 | 1 | All 4 integrators on one chip |
| LM339 quad comparator | DIP-14 | 1 | All 4 output stages on one chip |
| MCP4131 digital pot | SPI, 10kΩ, DIP-8 | 6 | 4-node needs N(N-1)/2 = 6 couplings |
| MCP3008 ADC | 10-bit 8-ch SPI, DIP-16 | 1 | Reads spin voltages |
| MCP4921 DAC | 12-bit SPI, DIP-8 | 1 | Bias control (optional at first) |
| Resistor 10kΩ | 1/4W | 20 | Summing inputs + feedback |
| Resistor 100kΩ | 1/4W | 10 | Integrator Rf, Schmitt feedback |
| Resistor 1MΩ | 1/4W | 4 | Noise injection limiter |
| Capacitor 10nF | ceramic or film | 4 | Integrator Cf (one per node) |
| Capacitor 100nF | ceramic | 6 | Decoupling on each IC power pin |
| 2N3904 or BC547 | NPN transistor | 1 | Reverse-biased noise source |
| Dual power supply | ±12V, 300mA min | 1 | Op-amp and comparator rails |
| 5V regulator | 7805 or LM2937-5 | 1 | SPI chip logic supply |
| Protoboard | ~60×80mm Veroboard | 1 | Or 2× half-size |

**Approximate cost: $15–25 AUD for 4-node prototype.**

#### Scaling to 8 nodes

Add: 1× TL084, 1× LM339, 22 more MCP4131 pots (total 28), more decoupling caps.
Cost delta: ~$15–20 AUD.

---

### 2.2 Power Supply

The op-amps and comparators need a **bipolar ±12V supply**. The SPI chips (MCP3008,
MCP4921, MCP4131) need 5V (or 3.3V).

#### Option A — Two 9V batteries (quick test, no mains)

```
  [9V battery A]         [9V battery B]
       (+)─────── +9V rail
       (-)─────┬─────── GND (analog common)
               │
       (+)─────┘
       (-)─────── -9V rail

  7805 regulator:
  +9V ──[IN]──7805──[OUT]── +5V
              [GND]──────── GND
```

Works fine for testing. Batteries drain quickly under load — use a bench supply for
extended runs.

#### Option B — Bench supply (recommended)

Set to ±12V dual-tracking. Connect `+12V`, `GND`, `−12V` to the board.
Derive 5V with a 7805 from the +12V rail.

#### Option C — Single 24V supply split with virtual ground

```
+24V ──── R 100Ω ──┬── R 100Ω ──── GND
                   │
                  +12V virtual (op-amp buffered with TL071)
```

Not recommended for first build — adds complexity.

#### Power decoupling (essential)

Place a **100nF ceramic cap** between each IC's VCC and GND pins, as close to the
chip as physically possible on the protoboard. Without this, high-frequency switching
on the SPI lines couples into the analog nodes and causes false transitions.

---

### 2.3 Single Spin Node — Full Circuit

Build and test one node completely before adding others.

```
                         +12V
                          │
                         ┌┤ TL084 pin 4 (V+)
                          │
        ┌─────────────────┤ (integrator op-amp, e.g. U1A pin 1,2,3)
        │                 │
        │    R1 10kΩ      │        Rf 100kΩ
IN_A ───┤───/\/\/──────(−)├───────/\/\/──────┐
        │                 │                   │
        │    R2 10kΩ     (+)── GND            │
IN_B ───┤───/\/\/──────   │                   │
        │                 │   Cf 10nF         │
        │    R3 10kΩ      ├────||─────────────┘
BIAS ───┴───/\/\/──────   │                   │
                          │     (out pin 1) ──┴──── V_int (integrator output)
                          │
                          │
                         ─┤ TL084 pin 11 (V-)
                          │
                        -12V
```

**Then the comparator stage (LM339):**

```
                         +12V
                          │
                         ┌┤ LM339 pin 3 (V+)
                          │
V_int ──────────── (+) pin 5
                   (−) pin 4 ──── GND (threshold = 0V)
                          │
              open-collector out pin 2
                          │
                    R_pull 10kΩ ──── +12V
                          │
                     SPIN_OUT ───── (also feeds back to coupling network)
                          │
              R_hys 100kΩ ─────────(+) pin 5   ← positive feedback for hysteresis
```

SPIN_OUT swings between:
- `+12V` (pulled high via R_pull, comparator output open) = **spin +1**
- `~0V` (comparator output sinks to GND) = **spin −1**

> Note: For a true ±12V output (needed for proper coupling), replace the pull-up
> with a totem-pole stage using two small signal transistors (2N3904 + 2N3906),
> or use an LM311 comparator which has a reference output pin that can be tied to −12V.

---

### 2.4 Coupling Between Nodes (MCP4131 Digital Pot)

Each coupling between spin i and spin j uses one MCP4131 (10kΩ digital pot).

```
SPIN_OUT_i ──── pin 1 (P0A) ──[wiper]── pin 6 (P0W) ──── R_sum 10kΩ ──── integrator input of node j
                pin 2 (P0B) ──── GND   (makes pot act as variable series resistor)

Same in reverse:
SPIN_OUT_j ──── same MCP4131 can't do both directions independently
              ← use a second MCP4131 for the reverse direction, or use a resistor
                summing network with a shared pot
```

**Simplified wiring for first build** (fixed coupling weights using fixed resistors):

Replace each MCP4131 with a fixed resistor to get the machine running without SPI
complexity. Once the analog dynamics work, substitute pots.

```
SPIN_OUT_i ──── 22kΩ ──── integrator (−) input of node j
SPIN_OUT_j ──── 22kΩ ──── integrator (−) input of node i
```

Use 22kΩ for antiferromagnetic coupling (Max-Cut). Use 10kΩ for stronger coupling.

---

### 2.5 Noise Injection Circuit

```
        +12V
         │
        100kΩ
         │
         ├──── Collector of 2N3904 (left floating / reverse biased)
         │
        Base ──── GND      ← base shorted to emitter = reverse-biased B-E junction
         │
        Emitter ──── noise output (~5–20mV white noise)
         │
        [TL084 unity-gain buffer]  ← pin 3(+), pin 1 out tied to pin 2(-)
         │
     out ──── 1MΩ ──┬──── 1MΩ ──┬──── 1MΩ ──┬──── ...
                    │            │             │
              node0 (−)    node1 (−)    node2 (−)    ← inject into each integrator input
```

The 1MΩ resistors keep the noise injection weak (~50× weaker than the signal inputs)
while reaching all nodes simultaneously. This gives a shared thermal-like bath.

To make noise amplitude controllable: insert a voltage divider using a MCP4131 between
the buffer output and the injection resistors, and drive that pot from the DAC or Z80.

---

### 2.6 Protoboard Layout Guide

Use **Veroboard** (strip board) with the strips running horizontally.

```
Strip board — top view, columns A..Z, rows 1..30

Row  1: +12V bus ─────────────────────────────────────────
Row  2: GND  bus ─────────────────────────────────────────
Row  3: -12V bus ─────────────────────────────────────────
Row  4: +5V  bus ─────────────────────────────────────────
Row  5: (gap)
Row  6-9:   TL084 U1 (pins 1-14, straddles gap in centre)
Row 10-13:  LM339 U2 (comparators)
Row 14:     (gap)
Row 15-18:  MCP4131 U3 (coupling 0-1)
Row 19-22:  MCP4131 U4 (coupling 0-2)
Row 23-26:  MCP4131 U5 (coupling 0-3)
Row 27-30:  MCP4131 U6 (coupling 1-2)
            (continue on second board for U7, U8, U9...)
```

**Strip cuts required:** Cut each strip under every IC pin that connects to a
different net. Use a 3mm drill bit or track cutter. Mark cuts with a marker before
drilling.

**Build order:**
1. Install and test the power rails (measure voltages before inserting any ICs)
2. Install TL084 — wire one integrator node, test with a bench signal
3. Install LM339 — wire one comparator, verify ±12V switching
4. Connect one coupling resistor between node 0 and node 1
5. Apply power — the two nodes should oscillate and then settle to opposite states
6. Replace fixed coupling resistors with MCP4131 pots one at a time
7. Add the noise injection circuit last

---

### 2.7 Testing Without a Z80

Before connecting any digital control, verify the analog behaviour with a multimeter
and oscilloscope (or even just LEDs):

```
Test 1 — Single node self-oscillation
  Wire one integrator with no input coupling. Apply power.
  The node should sit at +12V or -12V (bistable). Tap the output briefly to GND —
  it should flip to the other state and stay there.

Test 2 — Two coupled nodes (antiferromagnetic)
  Connect two nodes via a 22kΩ resistor (each driving the other's input).
  Apply power. The nodes should snap to OPPOSITE states: (+12V, -12V).
  If they snap to the SAME state, the coupling polarity is inverted — swap
  the resistor connection from the (+) input to the (-) input.

Test 3 — Two coupled nodes (ferromagnetic)
  Connect via a 22kΩ to the (+) input instead. Nodes should snap to SAME state.

Test 4 — Four fully connected antiferromagnetic nodes (Max-Cut)
  Connect all 6 pairs via 22kΩ. Apply power. One of the two valid Max-Cut
  solutions should appear: (+-+- or -+-+). Run several power cycles — you
  should see different valid solutions each time (random initial conditions).
```

**LED indicators:** Wire a red LED + 1kΩ from each SPIN_OUT to GND. LED on = +12V
= spin +1. Easy to read the solution state at a glance without a meter.

---

### 2.8 Z80 SPI Port Map

Once the analog board is verified, connect to the TEC-1 via the expansion port.

```
Port $10  — SPI data byte (MOSI write / MISO read via bit-bang)
Port $11  — SPI clock + CS control register
Port $12  — Chip select lines  bit0=ADC_CS  bit1=DAC_CS  bit2=POT_CS
Port $13  — Reset pulse (any OUT to this port triggers reset)
```

Connect to the TEC-1 I/O expansion connector. The TEC-1 exposes the Z80 data bus,
address bus, /IORQ, /RD, /WR lines. Decode ports $10–$13 with a 74HC138 3-to-8
decoder:

```
A3 A2 A1 A0 → 74HC138 select → /CS for port latches (74HC374 or 74HC595)
/IORQ + /WR  → 74HC138 enable
```

If you only need SPI (no parallel bus), a single **74HC595** shift register driven by
two Z80 port bits (data + clock) is the simplest interface.

---

## Part 3 — GPIO Interfacing

This section covers connecting the analog Ising board to GPIO-capable hosts: a
Raspberry Pi (runs `ising_sim.m`), Arduino (stand-alone monitoring), or directly back
to the TEC-1 Z80.

The key challenge is **voltage level translation**: the analog board operates at
**±12V**, GPIO pins expect **0–3.3V or 0–5V**.

---

### 3.1 Spin Output → GPIO Input (±12V to 3.3V/5V)

Each spin output swings between approximately +12V and −12V (or 0V depending on
comparator pull-up wiring). This must be clamped to safe GPIO levels.

#### Method A — Resistor divider + Schottky clamp (simplest)

Use this when spin output swings 0V to +12V (single-supply comparator with pull-up):

```
SPIN_OUT (+12V or 0V)
     │
    47kΩ
     │
     ├──────── GPIO_IN (3.3V pin)
     │
    22kΩ
     │
    GND

Divider ratio: 22/(47+22) = 0.32 → 12V × 0.32 = 3.84V → slightly over 3.3V
Add a BAT85 Schottky diode from GPIO_IN to 3.3V rail (cathode to rail) to clamp.
```

For a ±12V swing (true bipolar), add a second clamp diode to GND:

```
SPIN_OUT (±12V)
     │
    100kΩ
     │
     ├──── BAT85 anode → cathode to 3.3V   ← clamps positive rail
     │
     ├──── BAT85 cathode → anode to GND    ← clamps below 0V
     │
    GPIO_IN

The 100kΩ limits current through the clamp diodes to safe levels.
Safe for Raspberry Pi GPIO (max ±0.5V beyond rail).
```

#### Method B — Dedicated level shifter IC (cleanest)

Use a **TXS0108E** (8-channel bidirectional) or **74AHCT125** (unidirectional, 5V→3.3V).

```
SPIN_OUT (0–5V only!) ──── 74AHCT125 input ──── GPIO_IN (3.3V)
                            OE tied LOW
                            VCC = 3.3V

Note: 74AHCT125 is unidirectional. For ±12V inputs, use the resistor+clamp
method first to bring signals to 0–5V, then use this for 5V→3.3V conversion.
```

#### Method C — Optocoupler (complete galvanic isolation, recommended for safety)

```
SPIN_OUT (+12V / 0V)
     │
    1kΩ
     │
   PC817 LED anode ──── PC817 LED cathode ──── GND (analog)

   PC817 collector ──── 10kΩ ──── +3.3V (RPi)
   PC817 emitter   ──── GPIO_IN (RPi) ──── GND (RPi)

Logic: SPIN=+12V → LED on → transistor on → GPIO pulled LOW (inverted)
       SPIN=0V   → LED off → transistor off → GPIO pulled HIGH
```

Use optocouplers when the analog board has a separate GND from the RPi/Z80.
Prevents ground loops and protects the Pi from any fault on the analog side.

---

### 3.2 GPIO Output → Analog Board Control (3.3V to ±12V)

To drive the analog reset line or inject a simple bias from GPIO, the 3.3V GPIO
signal must be level-shifted up.

#### Method A — N-channel MOSFET switch (for reset pulse)

```
GPIO_OUT (3.3V logic) ──── 10kΩ ──── Gate of 2N7000 or BS170
                                      Source ──── GND (analog board)
                                      Drain ──── Reset line (pulled to +12V via 10kΩ)

GPIO HIGH → MOSFET on → Reset line pulled LOW → triggers reset
GPIO LOW  → MOSFET off → Reset line at +12V (inactive)
```

#### Method B — Op-amp level shifter (for analog bias voltages)

To output an analog voltage from the RPi's PWM (or a small DAC) to the ±12V domain:

```
RPi PWM output ──── RC filter (10kΩ + 10µF) ──── smoothed DC 0–3.3V
                                                      │
                                               TL071 non-inverting amp
                                               Gain = (R2/R1 + 1) = (47k/10k + 1) = 5.7×
                                               Output = 0–18.8V... too high.

Better: use a difference amplifier to map 0–3.3V → -12V to +12V:
    Vout = (Vin - 1.65) × (12/1.65) ≈ Vin × 7.27 - 12
    Set R1=R2=10kΩ, R3=R4=68kΩ and reference = 1.65V (from divider on +3.3V)
```

For most builds, just use the **MCP4921 DAC** (driven by SPI from RPi or Z80) for
bias control. It takes 5V supply and outputs 0–5V, then use the op-amp shifter above
to stretch to ±12V.

---

### 3.3 Raspberry Pi SPI Wiring to the Board

The MCP3008, MCP4921, and MCP4131 all use SPI (mode 0,0 — CPOL=0, CPHA=0). Wire
them to the RPi hardware SPI pins for best performance:

```
Raspberry Pi (BCM pin numbers)       Analog Board

Pin 19  GPIO10  MOSI  ──────────────  MOSI (all SPI devices in parallel)
Pin 21  GPIO9   MISO  ──────────────  MISO (all SPI devices in parallel)
Pin 23  GPIO11  SCLK  ──────────────  SCLK (all SPI devices in parallel)

Pin 24  GPIO8   CE0   ──────────────  CS of MCP3008  (ADC)
Pin 26  GPIO7   CE1   ──────────────  CS of MCP4921  (DAC)
Pin 22  GPIO25  (GPIO)─────────────  CS of MCP4131  (coupling pots, shared bus)
Pin 18  GPIO24  (GPIO)─────────────  Reset line (via MOSFET, see 3.2A)

Pin 2   5V      ──────────────────── VDD of all SPI chips + 7805 input
Pin 6   GND     ──────────────────── GND (digital side only — see note below)
```

> **Important — ground isolation:** The RPi GND and analog board GND should share
> one connection point only (star ground topology). Connect them at the power supply
> negative terminal, not at the protoboard. This prevents digital switching noise
> on the RPi from coupling into the sensitive analog integrators.

**SPI chip supply voltage note:**
- MCP3008: operates at 2.7V–5.5V. At 5V VDD, MISO output is 5V logic.
  Use a resistor divider (3.3kΩ + 1.8kΩ) on MISO before the RPi pin to
  bring 5V → 3.3V, or power the chip from the RPi 3.3V pin instead.
- MCP4921 and MCP4131: same range, same consideration.
- **Easiest fix:** power all three SPI chips from RPi pin 1 (3.3V, 50mA max).
  Current draw for all three is under 10mA total.

---

### 3.4 Raspberry Pi GPIO to Spin Output Wiring (8 spins)

This is the path that lets `ising_sim.m` output solved spin states to the GPIO pins,
which can then drive LEDs or be read by the TEC-1 as a result register.

```
Raspberry Pi                             LED indicators (optional)

Pin 11  GPIO17  ── 330Ω ── LED0 ── GND    Spin 0
Pin 13  GPIO27  ── 330Ω ── LED1 ── GND    Spin 1
Pin 15  GPIO22  ── 330Ω ── LED2 ── GND    Spin 2
Pin 16  GPIO23  ── 330Ω ── LED3 ── GND    Spin 3
Pin 18  GPIO24  ── 330Ω ── LED4 ── GND    Spin 4
Pin 22  GPIO25  ── 330Ω ── LED5 ── GND    Spin 5
Pin 29  GPIO5   ── 330Ω ── LED6 ── GND    Spin 6
Pin 31  GPIO6   ── 330Ω ── LED7 ── GND    Spin 7

LED on = spin +1 (solution group A)
LED off = spin −1 (solution group B)
```

To feed these back to the TEC-1 Z80 as an input port, connect all 8 lines through
a **74HC245** bus buffer to the Z80 data bus, decoded to an input port address
($10 in the MINT driver). The Z80 then reads the spin solution just as it would from
the physical ADC.

---

### 3.5 Complete Wiring Summary Diagram

```
                    ┌──────────────────────────────────┐
  Raspberry Pi      │     Analog Ising Board           │
  (or TEC-1 Z80)    │                                  │
                    │  ┌────────┐   ┌────────┐         │
  MOSI ─────────────┼──┤MCP4131 ├───┤ TL084  ├─ SPIN0 ─┼── LED0
  MISO ─────────────┼──┤  POT   │   │  INT   │         │
  SCLK ─────────────┼──┤  SPI   │   │  NODE  ├─ SPIN1 ─┼── LED1
  CS_POT ───────────┼──┤(×6/28) ├───┤  ×4/8  │         │
                    │  └────────┘   └───┬────┘         │
  CS_ADC ───────────┼──┐               │               │
                    │  │  ┌────────┐   │ ┌────────┐    │
  CS_DAC ───────────┼──┼──┤MCP4921 ├───┴─┤ LM339  │    │
                    │  │  │  DAC   │     │  COMP  │    │
  RESET ────────────┼──┼──┤  bias  │     │  ×4/8  │    │
  (via MOSFET)      │  │  └────────┘     └────────┘    │
                    │  │                               │
                    │  └──┤MCP3008 ├── reads SPIN0-7 ──┘
                    │     │  ADC   │
                    │     └────────┘
                    │                                  │
                    │  [2N3904 noise] → [TL084 buf]    │
                    │       → 1MΩ to each node (−) in  │
                    │                                  │
                    │  Power: ±12V analog, +5V digital │
                    └──────────────────────────────────┘

  GPIO17-24 ── (output) ── LEDs showing solved spin states
  GPIO17-24 ── (output) ── 74HC245 ── Z80 data bus (TEC-1 input port)
```

---

### 3.6 Enabling GPIO in `ising_sim.m`

Edit the top of the file:

```octave
use_gpio   = true;        % enable sysfs GPIO
GPIO_PINS  = [17 27 22 23 24 25 5 6];  % BCM pin numbers, one per spin
```

Run with permission:

```bash
# Option 1: run as root
sudo octave ising_sim.m

# Option 2: add user to gpio group (persistent, preferred)
sudo usermod -aG gpio $USER
newgrp gpio
octave ising_sim.m
```

After pressing `s` to solve, the GPIO pins update once per solve with the final
binarised spin state. The LED bar shows the solution visually at the same time as
the on-screen plot updates.

---

### Z80 SPI port map

```
Port $10  — SPI data byte (MOSI write / MISO read)
Port $11  — SPI clock + bit-bang control
Port $12  — Chip select lines (bit0=ADC, bit1=DAC, bit2=POT)
Port $13  — Reset pulse (any write triggers hardware reset)
```

Connect to the TEC-1 I/O expansion port. Use a 74HC595 shift register if direct
port I/O is not available.

---

## Part 3 — MINT2 Driver (`ising.mint`)

### Loading onto TEC-1

Paste or transfer `ising.mint` via serial to the TEC-1 MINT2 interpreter. All words
use single uppercase letters to comply with MINT2 naming rules.

### Word reference

| Word | Stack effect | Description |
|---|---|---|
| `I` | `--` | Initialise all arrays (spins, biases, couplings to zero) |
| `A` | `byte -- byte` | SPI byte transfer (send and receive simultaneously) |
| `Q` | `ch -- val` | Read ADC channel `ch` (0-7), returns 0–1023 |
| `D` | `val node --` | Write DAC bias value to node (0-4095) |
| `C` | `weight i j --` | Set coupling J[i][j] via digital potentiometer (0-128) |
| `E` | `--` | Hardware reset pulse |
| `W` | `n --` | Busy-wait delay (~n × 100µs) |
| `R` | `--` | Read all N spins from ADC into spin array `s` |
| `H` | `--` | Show spin states as `+ -` symbols |
| `V` | `--` | Show raw ADC values for all spins |
| `P` | `--` | Load Max-Cut problem (4-node, coupling weight 64) |
| `X` | `--` | Load ring-8 problem (8-node, coupling weight 64) |
| `S` | `--` | Solve: reset hardware + wait 20ms + read spins |
| `G` | `--` | Print estimated energy (experimental) |
| `M` | `--` | Main interactive loop (keyboard driven) |

### Typical session

```
> I          initialise
> P          load Max-Cut 4-node problem
> S          solve (hardware settles, reads spins)
> H          show result: [+ - + -]  means nodes 0,2 in group A; 1,3 in group B
```

Or run the interactive shell:

```
> M
ISING MACHINE CONTROLLER
S=solve H=show P=maxcut X=ring8 Q=quit
> S
RST
SPINS: + - + -
> H
SPINS: + - + -
```

### Writing your own problem in MINT

Set couplings manually with `C`. Weight `64` = middle of pot range (neutral), values
above 64 = ferromagnetic (spins align), below 64 = antiferromagnetic (spins oppose).

```
; Triangle graph — all antiferromagnetic (frustrated!)
:T
  32 0 1 C    ; J[0][1] = antiferro
  32 1 2 C
  32 0 2 C
  S H
;
```

Run it: `T`

### MINT coupling weight scale

| Weight | Jij effective | Effect |
|---|---|---|
| 0 | strongly negative | strong antiferromagnetic |
| 64 | zero | no coupling |
| 128 | strongly positive | strong ferromagnetic |

### Multi-shot statistics (MINT)

Run the solver several times and count results to estimate solution quality:

```
:Z
  16 (
    S H
  )
;
```

Then observe which configuration appears most often — that is the ground state.

---

## Part 4 — Mapping Optimization Problems

### Max-Cut

Split N nodes into two groups maximising the number of edges crossing between them.

```
Coupling:  Jij = negative (antiferromagnetic) for every edge (i,j)
Bias:      hi  = 0
Solution:  nodes with spin +1 are group A, spin -1 are group B
```

### Graph colouring (2-colour)

Same as Max-Cut — antiferromagnetic couplings between adjacent nodes.

### SAT (simplified)

Map each boolean variable to a spin. Clause penalties become ferromagnetic couplings
between variables that must agree, antiferromagnetic where they must differ.

### Travelling salesman (small N)

Encode city ordering as a spin pattern. Requires penalty terms in biases and couplings
to enforce valid tours. Practical up to ~8 cities with 16 spins.

---

## Part 5 — Troubleshooting

### Simulation (Octave)

| Symptom | Likely cause | Fix |
|---|---|---|
| Plot window doesn't open | No display | Run with `DISPLAY=:0 octave ising_sim.m` |
| Energy never drops | Noise too high | Press `-` several times before `s` |
| Always same solution | Noise too low | Press `+` or set `anneal=false` |
| Slow on large N | Normal — O(N²) per step | Reduce `N` or increase `dt` |
| GPIO permission error | Not root / no gpio group | `sudo octave ising_sim.m` |

### Hardware (MINT)

| Symptom | Likely cause | Fix |
|---|---|---|
| All spins read same value | ADC CS not toggling | Check port $12 bit0 wiring |
| Spins never change | Reset not reaching board | Check port $13 wiring |
| No convergence | Noise injection open | Check 2N3904 noise circuit |
| DAC has no effect | SPI polarity wrong | Check CPOL/CPHA — MCP4921 uses mode 0,0 |
| Couplings have no effect | MCP4131 not receiving | Verify POT CS = port $12 bit2 |

---

## Part 6 — Extending the System

### Larger problems

- Increase `N` in `ising_sim.m` for simulation
- For hardware: add more TL084 nodes and MCP4131 pots (120 pots for 16 nodes)
- At 16 nodes you can usefully solve routing, scheduling, and small SAT problems

### Connecting simulation to hardware

Run `ising_sim.m` with `use_gpio = true`. The GPIO outputs mirror the solved spin
states. Connect these to the Z80 input port so MINT can read the simulation's answer
as if it were the analog board — useful for testing before the hardware is built.

### Memristor crossbar upgrade

Replace the MCP4131 digital pots with a memristor crossbar array. Coupling weights
persist without SPI reprogramming and the matrix multiply happens in-situ.
Compatible with the same MINT driver — only the `C` word needs updating for the
memristor write protocol.

### Noise annealing schedule from MINT

Drive the noise DAC with a ramp:

```
; Anneal: start loud, cool to quiet over 128 steps
:N
  E
  128 (
    128 /i - 0 D    ; write noise level to DAC node 0
    20 W
  )
  R H
;
```

---

## Part 7 — Theory: Why and How This Actually Works

Understanding the physics lets you predict behaviour, diagnose faults, and know which
direction to push improvements.

---

### 7.1 The Ising Model

The Ising model was originally a statistical physics model of ferromagnetism. Each
atom has a magnetic **spin** that can point either up (+1) or down (−1). Neighbouring
spins interact, and the whole system settles into the lowest-energy configuration.

The **Hamiltonian** (energy function) is:

```
E = − Σ(i<j) Jij · si · sj  −  Σi hi · si

where:
  si    = spin of node i  (+1 or -1)
  Jij   = coupling strength between nodes i and j
  hi    = external bias (magnetic field) on node i
```

The machine tries to minimise E. The coupling signs determine behaviour:

```
Jij > 0  (ferromagnetic)   → si and sj want to be the SAME sign
Jij < 0  (antiferromagnetic) → si and sj want to be OPPOSITE signs
```

Many hard optimisation problems can be cast into this form by choosing J and h
appropriately. When physics minimises E, it simultaneously solves the problem.

---

### 7.2 Why Op-Amps Implement This Naturally

An op-amp integrator accumulates the weighted sum of its inputs over time:

```
tau · dVout/dt = −Vout + Σj (Jij · Vj) + hi
```

This is **exactly the gradient descent on the Ising energy**. Each node's voltage
moves in the direction that reduces the total energy. When all nodes stop changing,
you are at a (local) energy minimum — a candidate solution.

The **comparator / Schmitt trigger** at the output forces the continuous voltage to
snap to +Vsat or −Vsat, producing a hard binary spin. This is the binarisation step.

The **tanh** version (used in the simulation) keeps a soft output during settling,
which gives smoother energy landscapes and avoids hard traps. The Schmitt version is
faster and simpler to build but more prone to local minima.

```
Continuous relaxation (tanh):          Bistable snap (Schmitt):

Vout                                   Vout
  │      ╭──────                         │         ┌──────
  │   ╭──╯                               │         │
  │───╯                                  │─────────┘
  │                  time                │              time
  └──────────────────                    └──────────────────

Settles gradually, escapes          Snaps fast, but can lock
local traps via noise               into local minima easily
```

---

### 7.3 The Role of Noise

Without noise, the system always settles to the **nearest local minimum** from the
starting conditions. This may not be the global minimum (best solution).

Noise acts like **temperature** in simulated annealing:

- High noise = high temperature → system explores widely, escapes traps
- Low noise = low temperature → system settles into the nearest minimum

The annealing schedule — starting hot and cooling gradually — gives the system time
to find the global minimum before committing.

In the hardware, noise comes from the **reverse-biased transistor junction**: shot
noise in a reverse-biased B-E junction is broadband white noise, easily amplified to
the ~10–50mV range needed.

---

### 7.4 The Coupling Matrix as a Problem Encoder

The coupling matrix J completely defines what problem the machine is solving.
Changing J reprograms the machine with a new problem.

**Max-Cut encoding:**

```
Graph:  A──B──C──D──A  (ring of 4)
             │
         each edge → Jij = −1  (antiferromagnetic)

The machine minimises E = −Σ Jij·si·sj = +Σ si·sj (for negative Jij)
i.e. it MAXIMISES disagreement = maximises the number of cut edges.
```

**Frustration** — when no assignment of spins can satisfy all couplings simultaneously
(e.g. a triangle with all antiferromagnetic couplings), the machine settles to the
best compromise. This is where multiple runs and statistics are needed.

---

### 7.5 What to Look For to Improve Performance

#### Problem: too many wrong answers

Root cause: noise too low (system snaps before exploring), or annealing too fast.

Fixes:
- Increase noise amplitude (raise pot on noise injection circuit)
- Slow the annealing schedule (`anneal_rate` closer to 1.0 in simulation)
- Run multiple shots and take lowest-energy result (multi-shot in MINT: word `Z`)
- Add a periodic global kick: briefly short all integrator capacitors to GND via
  a relay or CD4066 switch (controlled by Z80), then release — forces re-exploration

#### Problem: same wrong answer every time

Root cause: deep local minimum — the initial conditions always lead there.

Fixes:
- Use **random initial conditions**: before each run, inject a brief burst of high
  noise to scramble all nodes, then anneal. MINT word `E` (reset) should also
  scramble; if the reset circuit is too slow, add a random DAC bias burst.
- Add a correction feedback step (digital): after convergence, compute energy in
  MINT, compare to best known, if worse add a small bias to the most suspicious
  node and re-run.

#### Problem: settling time too long

Root cause: RC time constant too large or coupling resistors too high.

Fixes:
- Reduce Cf from 10nF to 4.7nF or 2.2nF (speeds up integrator 2–5×)
- Reduce coupling resistors from 22kΩ to 10kΩ (stronger coupling = faster pull)
- Reduce Rf from 100kΩ to 47kΩ (but watch for instability / oscillation)
- Use faster op-amps: OPA2134 or LT1057 instead of TL084

#### Problem: poor solution quality on dense graphs

Root cause: the all-to-all resistor coupling network has resistive loading effects —
each node's output is shared across many resistors, reducing the effective coupling
strength as N grows.

Fixes:
- Buffer each spin output with a TL074 unity-gain follower before the coupling
  network — the buffer drives the resistors, not the comparator output directly
- Use a lower impedance coupling network (lower resistor values + buffered outputs)
- Switch to time-multiplexed coupling (connect subsets of nodes at a time via
  CD4051 analog mux controlled by Z80) — reduces simultaneous loading

#### What the energy plot tells you (simulation)

```
Good solve:                    Bad solve (stuck):
E                              E
│╲                             │╲╱╲╱
│ ╲                            │     ╲╱╲╱╲
│  ╲___________                │           ╲╱  (noise, no convergence)
└──────────────                └─────────────

Action: fine                   Action: increase anneal_rate
                                       or reduce noise_amp
```

---

## Part 8 — Diagnostics with CRO and Logic Probe

This section covers how to systematically fault-find the circuit using a CRO
(oscilloscope) and a simple 5V logic probe.

---

### 8.1 Essential Test Points

Mark these test points on your protoboard before building:

```
TP1  — +12V rail (check: DC voltage, noise < 50mV)
TP2  — −12V rail (check: DC voltage, noise < 50mV)
TP3  — +5V rail  (check: DC voltage, ripple < 20mV)
TP4  — GND (reference for all measurements)
TP5  — Integrator output of node 0 (V_int0) — key waveform
TP6  — Spin output of node 0 (SPIN0) — should be hard +/−12V when settled
TP7  — Noise source output (after buffer) — should show noise waveform
TP8  — SPI SCLK line
TP9  — SPI MOSI line
TP10 — ADC CS line
```

---

### 8.2 Power Rail Checks (Multimeter first, CRO second)

Before inserting any ICs:

```
Check        Expected         Fault if not
+12V rail    +11.5 to +12.5V  Supply wiring, regulator fault
−12V rail    −11.5 to −12.5V  Dual supply fault, reversed connection
+5V rail     +4.75 to +5.25V  7805 fault, input undervoltage
GND          0V reference     Broken GND connection → everything wrong
```

With CRO on the ±12V rails, look for:
- AC ripple > 100mV peak-peak → insufficient decoupling, add 10µF electrolytic + 100nF ceramic at power entry
- High-frequency hash (>100kHz) → digital SPI switching coupling into analog rail → add ferrite bead in series with the analog supply line

---

### 8.3 Single Node Waveforms (CRO)

#### Test A — Integrator free-running (no coupling inputs, no noise)

```
Expected waveform on V_int (TP5):
  Sits at one of two values: approximately +Vsat or −Vsat of the TL084 (±10–11V)
  Does NOT oscillate unless there is instability.

If oscillating:
  ← Rf too low, or Cf too small → reduce gain, increase Cf
  ← Stray positive feedback path → check layout for coupling between output and input
```

#### Test B — Integrator with noise injection active

```
Expected waveform on V_int (TP5), CRO: AC coupled, 20mV/div, 10ms/div:
  Small noise riding on the DC level (~10–30mV peak-peak)
  Occasional random flips between +Vsat and −Vsat

If no noise visible:
  ← 2N3904 noise source not working → check reverse bias on B-E
  ← Buffer op-amp oscillating at RF → add 100pF from buffer output to −input
  ← Injection resistors too large → reduce from 1MΩ to 470kΩ

If too much noise (nodes switching rapidly):
  ← Injection resistors too small → increase to 2.2MΩ
  ← Buffer gain too high → add resistor divider at buffer output
```

#### Test C — SPIN output (TP6)

```
Expected waveform: clean ±12V square wave transitions when node flips
  Rise/fall time: < 1µs (LM339 comparator)
  Final settled state: solid +12V or −12V, no oscillation

If intermediate voltage (not rail-to-rail):
  ← Comparator output not saturating → check +12V on LM339 V+ pin
  ← Pull-up resistor missing or wrong value → check 10kΩ to +12V on open-collector output
  ← LM339 output shorted → check for solder bridges

If rapid oscillation at settled state:
  ← Hysteresis resistor missing or wrong value → increase R_hys from 100kΩ to 220kΩ
  ← Output capacitive loading → add 10pF from output to GND to slow the comparator
```

---

### 8.4 Coupling Network Checks

Probe between two coupled nodes to verify coupling direction.

**Test procedure:**

1. Disconnect the noise source (remove the 1MΩ injection resistor temporarily).
2. Force SPIN0 to +12V by connecting its integrator (+) input to +12V briefly.
3. Measure the resulting voltage at the (−) input of node 1's integrator.

```
Expected: a small negative voltage at node 1's (−) input
  (negative because SPIN0 is positive, coupled inverted through summing amp)

If zero: coupling resistor open, MCP4131 not configured (wiper disconnected)
If positive: coupling polarity inverted — swap P0A and P0B on the MCP4131
If very large: coupling resistance too low — recheck resistor values
```

**CRO dual-channel coupling test:**

```
CH1: SPIN0 output
CH2: SPIN1 output
Timebase: 50ms/div

With antiferromagnetic coupling, when power is applied:
  → both channels flip briefly, then one goes to +12V and the other to −12V
  → they should NOT both sit at the same value

If both channels sit at the same value:
  ← Coupling polarity is ferromagnetic (swapped) → reverse coupling resistor connection
  ← One node is dead and the other is dominating → check node separately
```

---

### 8.5 SPI Communication Checks (Logic Probe + CRO)

Use a logic probe (5V type) on the SPI lines.

#### Logic probe spot-checks

```
Line      Expected during SPI transaction   Fault if not
SCLK      pulsing (8 pulses per byte)       Port $11 not toggling → check Z80 OUT
MOSI      changing data pattern             Port $10 not loaded → check MINT word A
CS_ADC    pulses LOW during ADC read        Port $12 bit0 not driven → wiring
CS_DAC    pulses LOW during DAC write       Port $12 bit1 not driven → wiring
CS_POT    pulses LOW during pot write       Port $12 bit2 not driven → wiring
MISO      changes during ADC read           ADC not responding → check VDD, GND
```

#### CRO SPI waveform (normal)

```
SCLK:  ───┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌────   8 clean clock pulses per byte
          └┘└┘└┘└┘└┘└┘└┘└┘

MOSI:  ─── D7 D6 D5 D4 D3 D2 D1 D0 ───   stable data on rising edge

CS:    ─────┐                    ┌─────
            └────────────────────┘       LOW for duration of transfer
```

If SCLK shows ringing or slow edges:
- Add 33Ω series resistor on SCLK line close to source
- Shorten the physical wire length

If MISO is not changing during ADC reads:
- Verify ADC VDD connected to 3.3V or 5V
- Verify ADC GND connected
- Verify SCLK and MOSI are reaching the ADC chip (probe at IC pin, not at far end of wire)

---

### 8.6 End-to-End System Check (CRO 4-channel ideal)

With 4 CRO channels on the four spin outputs of a 4-node system, apply power and
watch for the settling sequence:

```
t=0ms   Power applied
        All nodes at mid-rail or random state — expect rapid transitions

t=1-5ms Nodes flip repeatedly as they find equilibrium
         Expect: alternating high-low transitions, possibly oscillating

t=5-20ms System settles
         Expect: each channel stable at ±12V, no further transitions
         Valid Max-Cut solution: alternating (+−+−) or (−+−+) pattern

If settling takes > 100ms:
  ← RC time constant too large → reduce Cf or coupling resistors

If system never settles (continuous oscillation after 100ms):
  ← Noise too high → reduce noise injection
  ← Hysteresis too low → increase R_hys
  ← Coupling too strong and creating limit cycle → increase coupling resistors

If all nodes go to same state (++++):
  ← All couplings are ferromagnetic → check coupling polarity (see 8.4)
  ← Noise source not working → nodes can't escape dominant state
```

---

### 8.7 Quick-Reference Fault Table

| Symptom | Where to probe | Expected signal | Likely fault |
|---|---|---|---|
| Node stays at mid-rail ~0V | V_int (TP5) | DC at ±10V settled | Integrator output stage, check TL084 pin 8 (V+) |
| Node oscillates continuously | V_int + SPIN_OUT | DC after settling | R_hys too small, add/increase hysteresis resistor |
| No SPI response from ADC | MISO line at ADC pin | Changing data | ADC power or ground missing |
| Coupling has no effect | Both spin outputs | Opposite states | Coupling polarity inverted, or MCP4131 wiper not connected |
| Noise always drives same solution | All spin outputs | Random initial flip | Noise injection one-sided — check buffer output can swing negative |
| Digital switching visible on V_int | V_int (AC coupled) | Only thermal noise | Shared GND path — star-ground the analog and digital GND |
| +5V rail < 4.5V | TP3 | +5V stable | 7805 input too low, check input ≥ 7V, or replace with 3.3V LDO |
| Op-amp output clipped at ±10V not ±12V | SPIN_OUT | ±12V | Normal for TL084 — Vsat ≈ VCC − 2V, not a fault |

---

## File Structure

```
Cascaded-Modulator-Ising-Machine-CMIM/
├── README.md           ← background theory and hardware design notes
└── cmim-sim/
    ├── HOW-TO.md       ← this file
    ├── ising_sim.m     ← Octave simulation (run this first)
    └── ising.mint      ← MINT2 driver for TEC-1/Z80 hardware
```
