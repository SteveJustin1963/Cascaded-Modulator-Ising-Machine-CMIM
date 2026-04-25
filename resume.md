steve@steve-MS-7592:~/Cascaded-Modulator-Ising-Machine-CMIM$ nano README.md
steve@steve-MS-7592:~/Cascaded-Modulator-Ising-Machine-CMIM$ nano README.md
steve@steve-MS-7592:~/Cascaded-Modulator-Ising-Machine-CMIM$ claude --dangerously-skip-permissions
╭─── Claude Code v2.1.72 ─────────────────────────────────────────────────────────────────────────────────────────╮                                             
│                                             │ Tips for getting started                                          │                                             
│             Welcome back Steve!             │ Run /init to create a CLAUDE.md file with instructions for Claude │                                             
│                                             │ ───────────────────────────────────────────────────────────────── │                                             
│                   ▐▛███▜▌                   │ Recent activity                                                   │                                             
│                  ▝▜█████▛▘                  │ No recent activity                                                │                                             
│                    ▘▘ ▝▝                    │                                                                   │                                             
│                                             │                                                                   │                                             
│   Sonnet 4.6 · Claude Pro · Steve Justin    │                                                                   │                                             
│   ~/Cascaded-Modulator-Ising-Machine-CMIM   │                                                                   │                                             
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯                                             
                                                                                                                                                                
❯ read the README. check this info and see if can be done, checkj for errors  and using  /MINT  code, write octave code as an alternatove, that handles gpio    
and graphing and control via kb commands                                                                                                                        
                                                                                                                                                                
● Read 2 files (ctrl+o to expand)                                                                                                                               
                                                                                                                                                                
● Let me check what files are in the project directory:                                                                                                         
                           
● Read 1 file (ctrl+o to expand)                                                                                                                                
                                                                                                                                                                
● Let me also check for the MINT language reference on the system:                                                                                              
                                                                                                                                                                
● Searched for 4 patterns, read 3 files (ctrl+o to expand)                                                                                                      
                                                                                                                                                                
● Now I have enough context. Let me write both files.                                                                                                           
                                                                                                                                                                
● Read 1 file (ctrl+o to expand)                                                                                                                                
                                                                                                                                                                
● Feasibility + error notes first:                                                                                                                              
                                                                                                                                                                
  - Architecture is sound — TL084 + MCP4131/MCP4921/MCP3008 + Z80 SPI is a real buildable system                                                                
  - README MINT code is pseudo-Forth — SPIN@, BIAS!, COUPLE!, WAIT, OUT are not valid MINT2 syntax                                                              
  - MINT2 functions must be single uppercase letters; I/O uses /I (port read) and /O (port write)                                                               
  - ADCREAD/DACWRITE/POTWRITE are undefined stubs
  - The 200 WAIT delay needs loop-based busy-wait in MINT                                                                                                       
  - 1 40 OUT should be 40 1 /O in MINT2                           

  Now writing both files:

● Write(ising.mint)                                   
  ⎿  Wrote 234 lines to ising.mint                                                        
     ; ============================================================
     ; CMIM - Ising Machine MINT2 driver for TEC-1 / Z80                                                                                                        
     ; ============================================================
     ; Hardware:                                                                                                                                                
     ;   MCP3008  ADC  - read 8 spin voltages  (SPI, CS = port $12 bit0)
     ;   MCP4921  DAC  - write 8 bias values   (SPI, CS = port $12 bit1)                                                                                        
     ;   MCP4131  POT  - write 28 couplings    (SPI, CS = port $12 bit2)
     ;   SPI data/clk  - port $10 (data), port $11 (CLK/CS control)
     ;   Reset pulse   - port $13 (any write)
     ;
     … +224 lines (ctrl+o to expand)

● Now the Octave simulation with GPIO, graphing, and keyboard control:
                                                                                          
● Write(ising_sim.m)                                  
  ⎿  Wrote 346 lines to ising_sim.m                                                                                                                             
     % ============================================================
     % CMIM - Ising Machine Simulator (Octave)                                                                                                                  
     % Simulates analog op-amp Ising dynamics with:               
     %   - leaky integrator + tanh nonlinearity per node                                                                                                        
     %   - noise injection (simulated annealing)                  
     %   - real-time plotting
     %   - keyboard control
     %   - optional Linux sysfs GPIO output (for hardware integration)
     %
     % Keyboard commands:
     … +336 lines (ctrl+o to expand)

● Bash(octave --norc --no-gui -q --eval "             
      % Quick syntax/logic check - run without display…)                                  
  ⎿  QSocketNotifier: Can only be used with threads started with QThread
     Spins:   -1  -1   1   1   1   1   1   1                                                                                                                    
     Energy: 0.5000                                   
     PASS                                                                                                                                                       
                                                                  
● Dynamics work correctly. Let me also verify the MINT file has no obvious structural issues:                                                                   
                                                                                          
● Searched for 1 pattern (ctrl+o to expand)                                                                                                                     
                                                                                                                                                                
● Both files created. Here's a summary:               
                                                                                                                                                                
  ---                                                             
  Feasibility: Yes, buildable                                                                                                                                   
                                                                  
  The hardware stack (TL084 + MCP3008/4921/4131 via SPI) is real and widely available. The physics is sound.                                                    
                                                                  
  README errors found

  ┌───────────────────────────────────────┬─────────────────────────────────────┐
  │                 Issue                 │                 Fix                 │
  ├───────────────────────────────────────┼─────────────────────────────────────┤
  │ SPIN@, BIAS!, COUPLE! not valid MINT2 │ Single-letter words: Q, D, C        │
  ├───────────────────────────────────────┼─────────────────────────────────────┤
  │ WAIT undefined                        │ W = ( 255 ( ) ) busy-wait loop      │
  ├───────────────────────────────────────┼─────────────────────────────────────┤
  │ 1 40 OUT wrong syntax                 │ $13 1 /O in MINT2                   │
  ├───────────────────────────────────────┼─────────────────────────────────────┤
  │ ADCREAD/DACWRITE/POTWRITE are stubs   │ Full SPI byte-bang routines A, Q, D │
  ├───────────────────────────────────────┼─────────────────────────────────────┤
  │ 200 WAIT in SOLVE with no delay unit  │ 200 W with defined W                │
  └───────────────────────────────────────┴─────────────────────────────────────┘

  ---
  Files created

  ising.mint — MINT2 driver for TEC-1/Z80:
  - I = init arrays | M = interactive main loop
  - Q = ADC read spin | D = DAC write bias | C = POT write coupling
  - S = solve (reset + wait + read) | H = show spin signs | V = verbose raw values
  - P = Max-Cut 4-node | X = ring-8 problem

  ising_sim.m — Octave simulation (verified working):
  - Leaky integrator + tanh(gain*u) nonlinearity (soft, not hard Schmitt)
  - Noise injection with simulated annealing (noise * 0.995^step)
  - Real-time 4-panel plot: spins / J matrix / energy history / phase space
  - Keyboard: s=solve p=maxcut x=ring r=random +/-=noise g=GPIO q=quit
  - Linux sysfs GPIO output (BCM pins 17-24, set use_gpio=true)

✻ Brewed for 14m 34s                                  
                                                                                          
❯ Can you write me a nice how-to.md manual regarding the work that you've just done and put all the new work in its own folder                                  
                                                                                                                                                                
● Bash(mkdir -p /home/steve/Cascaded-Modulator-Ising-Machine-CMIM/cmim-sim && mv /home/steve/Cascaded-Modulator-Ising-Machine-CMIM/ising.mint                   
      /home/steve/Cascaded-Modu…)                                                                                                                               
  ⎿  ising.mint                                                                                                                                                 
     ising_sim.m                                                  
                                                                                                                                                                
● Write(cmim-sim/HOW-TO.md)                                       
  ⎿  Wrote 394 lines to cmim-sim/HOW-TO.md                                                                                                                      
     # CMIM — Cascaded Modulator Ising Machine                                                                                                                  
     ## How-To Manual: Simulation & Z80/MINT Driver                                                                                                             
                                                                                                                                                                
     ---                                                                                                                                                        
                                                                  
     ## What This Is                                                                                                                                            
                                                                  
     An **Ising machine** is a physical system that solves hard optimization problems by
     letting physics find the lowest-energy configuration instead of calculating every
     possibility digitally. The **Cascaded Modulator Ising Machine (CMIM)** is a photonic
     … +384 lines (ctrl+o to expand)

● Read 1 file (ctrl+o to expand)                    
                                                                                          
● Done. Final structure:
                                                                                                                                                                
  Cascaded-Modulator-Ising-Machine-CMIM/                                                  
  ├── README.md           ← original theory notes                                                                                                               
  └── cmim-sim/                                                                                                                                                 
      ├── HOW-TO.md       ← manual (12KB)
      ├── ising_sim.m     ← Octave simulation                                                                                                                   
      └── ising.mint      ← MINT2 Z80 driver                      

  The HOW-TO.md covers six sections:

  1. Octave simulation — how to run, all keyboard commands, the four plot panels, tunable parameters with tips for stuck/noisy/slow behaviour
  2. Hardware build — full BOM for an 8-node starter board (~$30–60 AUD), spin node circuit diagram, noise injection circuit, Z80 port map
  3. MINT2 driver — word reference table, typical session transcript, how to write your own problem, coupling weight scale, multi-shot statistics
  4. Problem mapping — Max-Cut, graph colouring, SAT, TSP encoding explained
  5. Troubleshooting — separate tables for Octave and hardware faults with fixes
  6. Extensions — scaling to 16 nodes, connecting sim to hardware via GPIO, memristor upgrade path, MINT noise annealing schedule

✻ Churned for 1m 39s                                
                                                                                          
❯ have add any info on building th ectiot and how to interfsce it to the gpio ?                                                                                 
  ⎿  Interrupted · What should Claude do instead?                                                                                                               
                                                                                                                                                                
❯ have add any info on building the circuit  and how to interfsce it to the gpio ?                                                                              
                                                                                                                                                                
● Read 1 file (ctrl+o to expand)                                                                                                                                
                                                                                                                                                                
● Good call — Part 2 needs much more depth. I'll expand it substantially with step-by-step build instructions, full circuit details, and a complete GPIO        
  interfacing section.                                            
                                                                                                                                                                
● Update(cmim-sim/HOW-TO.md)                                                                                                                                    
  ⎿  Added 521 lines, removed 42 lines                                                                                                                          
      130                                                                                                                                                       
      131  ## Part 2 — Physical Hardware Build                                                                                                                  
      132                                                                                                                                                       
      133 -Before using the MINT driver, you need the hardware. This section describes the                                                                      
      134 -coprocessor board that `ising.mint` is designed to control.                                                                                          
      133 +This section is a complete build guide. Start with a single 4-node prototype on                                                                      
      134 +protoboard, verify it works, then scale up.                                                                                                          
      135                                                                                                                                                       
      136 -### Bill of Materials (8-node starter board)                                                                                                  
      136 +---                                                                                                                                           
      137   
      138 -| Part | Value / Part# | Qty | Purpose |                                                                                                      
      138 +### 2.1 Bill of Materials                                                                                                                     
      139 +                                                                                                                                              
      140 +#### 4-node prototype (cheapest, build first)                                                                                                 
      141 +                                                                                                                                              
      142 +| Part | Value / Part# | Qty | Notes |                                                                                                        
      143  |---|---|---|---|
      144 -| TL084 quad op-amp | DIP-14 | 2 | Spin node integrators (4 per chip) |                                                                       
      145 -| LM339 quad comparator | DIP-14 | 2 | Spin output binarisation |                                                                             
      146 -| MCP4131 digital potentiometer | SPI, 10kΩ, DIP-8 | 28 | Programmable coupling weights |                                                     
      147 -| MCP3008 ADC | 10-bit, 8-ch SPI, DIP-16 | 1 | Read 8 spin voltages |                                                                         
      148 -| MCP4921 DAC | 12-bit, SPI, DIP-8 | 1 | Write 8 bias voltages |                                                                              
      149 -| Resistors 10kΩ | 1/4W | 20 | Summing network |                                                                                              
      150 -| Resistors 100kΩ | 1/4W | 10 | Feedback / coupling |                                                                                         
      151 -| Capacitors 10nF | ceramic | 8 | Integrator capacitors (Cf) |                                                                                
      152 -| 2N3904 or BC547 NPN | — | 1 | Noise source (reverse-biased B-E) |                                                                           
      153 -| Power supply | ±12V, 500mA | 1 | Op-amp rails |                                                                                             
      154 -| 5V regulated | 100mA | 1 | Logic / SPI devices |                                                                                            
      144 +| TL084 quad op-amp | DIP-14 | 1 | All 4 integrators on one chip |                                                                            
      145 +| LM339 quad comparator | DIP-14 | 1 | All 4 output stages on one chip |                                                                      
      146 +| MCP4131 digital pot | SPI, 10kΩ, DIP-8 | 6 | 4-node needs N(N-1)/2 = 6 couplings |                                                          
      147 +| MCP3008 ADC | 10-bit 8-ch SPI, DIP-16 | 1 | Reads spin voltages |                                                                           
      148 +| MCP4921 DAC | 12-bit SPI, DIP-8 | 1 | Bias control (optional at first) |                                                                    
      149 +| Resistor 10kΩ | 1/4W | 20 | Summing inputs + feedback |                                                                                     
      150 +| Resistor 100kΩ | 1/4W | 10 | Integrator Rf, Schmitt feedback |                                                                              
      151 +| Resistor 1MΩ | 1/4W | 4 | Noise injection limiter |                                                                                         
      152 +| Capacitor 10nF | ceramic or film | 4 | Integrator Cf (one per node) |                                                                       
      153 +| Capacitor 100nF | ceramic | 6 | Decoupling on each IC power pin |                                                                           
      154 +| 2N3904 or BC547 | NPN transistor | 1 | Reverse-biased noise source |                                                                        
      155 +| Dual power supply | ±12V, 300mA min | 1 | Op-amp and comparator rails |                                                                     
      156 +| 5V regulator | 7805 or LM2937-5 | 1 | SPI chip logic supply |                                                                               
      157 +| Protoboard | ~60×80mm Veroboard | 1 | Or 2× half-size |                                                                                     
      158   
      159 -Approximate total cost: **$30–60 AUD** for 8 nodes.                                                                                           
      159 +**Approximate cost: $15–25 AUD for 4-node prototype.**                                                                                        
      160   
      161 -### Spin node circuit (per node)                                                                                                              
      161 +#### Scaling to 8 nodes                                                                                                                       
      162   
      163 +Add: 1× TL084, 1× LM339, 22 more MCP4131 pots (total 28), more decoupling caps.                                                               
      164 +Cost delta: ~$15–20 AUD.                                                                                                                      
      165 +                                                                                                                                              
      166 +---                                                                                                                                           
      167 +                                                                                                                                              
      168 +### 2.2 Power Supply                                                                                                                          
      169 +                                                                                                                                              
      170 +The op-amps and comparators need a **bipolar ±12V supply**. The SPI chips (MCP3008,                                                           
      171 +MCP4921, MCP4131) need 5V (or 3.3V).                                                                                                          
      172 +                                                                                                                                              
      173 +#### Option A — Two 9V batteries (quick test, no mains)                                                                                       
      174 +                                                                                                                                              
      175  ```
      176 -coupling inputs (from other spin outputs via MCP4131 pots)                                                                                    
      177 -         |                                                                                                                                    
      178 -    Σ resistor network (10kΩ per input)                                                                                                       
      179 -         |                                                                                                                                    
      180 -        (-) TL084 op-amp input                                                                                                                
      181 -         |                                                                                                                                    
      182 -    +----+----+                                                                                                                               
      183 -    |         |                                                                                                                               
      184 -   Cf 10nF   Rf 100kΩ     ← leaky integrator                                                                                                  
      185 -    |         |                                                                                                                               
      186 -    +---------+                                                                                                                               
      187 -         |                                                                                                                                    
      188 -        out → LM339 comparator → spin output ±12V                                                                                             
      189 -                     |                                                                                                                        
      190 -              10kΩ hysteresis feedback (Schmitt)                                                                                              
      176 +  [9V battery A]         [9V battery B]                                                                                                       
      177 +       (+)─────── +9V rail                                                                                                                    
      178 +       (-)─────┬─────── GND (analog common)                                                                                                   
      179 +               │                                                                                                                              
      180 +       (+)─────┘                                                                                                                              
      181 +       (-)─────── -9V rail                                                                                                                    
      182 +                                                                                                                                              
      183 +  7805 regulator:                                                                                                                             
      184 +  +9V ──[IN]──7805──[OUT]── +5V                                                                                                               
      185 +              [GND]──────── GND                                                                                                               
      186  ```
      187   
      188 -The comparator output is the spin state: `+12V = spin +1`, `−12V = spin −1`.                                                                  
      189 -That same output feeds back through MCP4131 pots to all other nodes.                                                                          
      188 +Works fine for testing. Batteries drain quickly under load — use a bench supply for                                                           
      189 +extended runs.                                                                                                                                
      190   
      191 -### Noise injection circuit                                                                                                                   
      191 +#### Option B — Bench supply (recommended)                                                                                                    
      192   
      193 +Set to ±12V dual-tracking. Connect `+12V`, `GND`, `−12V` to the board.                                                                        
      194 +Derive 5V with a 7805 from the +12V rail.                                                                                                     
      195 +                                                                                                                                              
      196 +#### Option C — Single 24V supply split with virtual ground                                                                                   
      197 +                                                                                                                                              
      198  ```
      199 -+12V ──── 100kΩ ──── Base (reversed) of 2N3904                                                                                                
      200 -                           |                                                                                                                  
      201 -                         Emitter ──── op-amp buffer (TL084 unity gain)                                                                        
      202 -                                           |                                                                                                  
      203 -                                      100kΩ ──── all integrator inputs                                                                        
      199 ++24V ──── R 100Ω ──┬── R 100Ω ──── GND                                                                                                        
      200 +                   │                                                                                                                          
      201 +                  +12V virtual (op-amp buffered with TL071)                                                                                   
      202  ```
      203   
      204 -The reverse-biased B-E junction generates white noise (~10–50mV).                                                                             
      205 -Buffer and inject via 100kΩ to each node. Amplitude controllable via DAC.                                                                     
      204 +Not recommended for first build — adds complexity.                                                                                            
      205   
      206 +#### Power decoupling (essential)                                                                                                             
      207 +                                                                                                                                              
      208 +Place a **100nF ceramic cap** between each IC's VCC and GND pins, as close to the                                                             
      209 +chip as physically possible on the protoboard. Without this, high-frequency switching                                                         
      210 +on the SPI lines couples into the analog nodes and causes false transitions.                                                                  
      211 +                                                                                                                                              
      212 +---                                                                                                                                           
      213 +                                                                                                                                              
      214 +### 2.3 Single Spin Node — Full Circuit                                                                                                       
      215 +                                                                                                                                              
      216 +Build and test one node completely before adding others.                                                                                      
      217 +                                                                                                                                              
      218 +```                                                                                                                                           
      219 +                         +12V                                                                                                                 
      220 +                          │                                                                                                                   
      221 +                         ┌┤ TL084 pin 4 (V+)                                                                                                  
      222 +                          │                                                                                                                   
      223 +        ┌─────────────────┤ (integrator op-amp, e.g. U1A pin 1,2,3)                                                                           
      224 +        │                 │                                                                                                                   
      225 +        │    R1 10kΩ      │        Rf 100kΩ                                                                                                   
      226 +IN_A ───┤───/\/\/──────(−)├───────/\/\/──────┐                                                                                                
      227 +        │                 │                   │                                                                                               
      228 +        │    R2 10kΩ     (+)── GND            │                                                                                               
      229 +IN_B ───┤───/\/\/──────   │                   │                                                                                               
      230 +        │                 │   Cf 10nF         │                                                                                               
      231 +        │    R3 10kΩ      ├────||─────────────┘                                                                                               
      232 +BIAS ───┴───/\/\/──────   │                   │                                                                                               
      233 +                          │     (out pin 1) ──┴──── V_int (integrator output)                                                                 
      234 +                          │                                                                                                                   
      235 +                          │                                                                                                                   
      236 +                         ─┤ TL084 pin 11 (V-)                                                                                                 
      237 +                          │                                                                                                                   
      238 +                        -12V                                                                                                                  
      239 +```                                                                                                                                           
      240 +                                                                                                                                              
      241 +**Then the comparator stage (LM339):**                                                                                                        
      242 +                                                                                                                                              
      243 +```                                                                                                                                           
      244 +                         +12V                                                                                                                 
      245 +                          │                                                                                                                   
      246 +                         ┌┤ LM339 pin 3 (V+)                                                                                                  
      247 +                          │                                                                                                                   
      248 +V_int ──────────── (+) pin 5                                                                                                                  
      249 +                   (−) pin 4 ──── GND (threshold = 0V)                                                                                        
      250 +                          │                                                                                                                   
      251 +              open-collector out pin 2                                                                                                        
      252 +                          │                                                                                                                   
      253 +                    R_pull 10kΩ ──── +12V                                                                                                     
      254 +                          │                                                                                                                   
      255 +                     SPIN_OUT ───── (also feeds back to coupling network)                                                                     
      256 +                          │                                                                                                                   
      257 +              R_hys 100kΩ ─────────(+) pin 5   ← positive feedback for hysteresis                                                             
      258 +```                                                                                                                                           
      259 +                                                                                                                                              
      260 +SPIN_OUT swings between:                                                                                                                      
      261 +- `+12V` (pulled high via R_pull, comparator output open) = **spin +1**                                                                       
      262 +- `~0V` (comparator output sinks to GND) = **spin −1**                                                                                        
      263 +                                                                                                                                              
      264 +> Note: For a true ±12V output (needed for proper coupling), replace the pull-up                                                              
      265 +> with a totem-pole stage using two small signal transistors (2N3904 + 2N3906),                                                               
      266 +> or use an LM311 comparator which has a reference output pin that can be tied to −12V.                                                       
      267 +                                                                                                                                              
      268 +---                                                                                                                                           
      269 +                                                                                                                                              
      270 +### 2.4 Coupling Between Nodes (MCP4131 Digital Pot)                                                                                          
      271 +                                                                                                                                              
      272 +Each coupling between spin i and spin j uses one MCP4131 (10kΩ digital pot).                                                                  
      273 +                                                                                                                                              
      274 +```                                                                                                                                           
      275 +SPIN_OUT_i ──── pin 1 (P0A) ──[wiper]── pin 6 (P0W) ──── R_sum 10kΩ ──── integrator input of node j                                           
      276 +                pin 2 (P0B) ──── GND   (makes pot act as variable series resistor)                                                            
      277 +                                                                                                                                              
      278 +Same in reverse:                                                                                                                              
      279 +SPIN_OUT_j ──── same MCP4131 can't do both directions independently                                                                           
      280 +              ← use a second MCP4131 for the reverse direction, or use a resistor                                                             
      281 +                summing network with a shared pot                                                                                             
      282 +```                                                                                                                                           
      283 +                                                                                                                                              
      284 +**Simplified wiring for first build** (fixed coupling weights using fixed resistors):                                                         
      285 +                                                                                                                                              
      286 +Replace each MCP4131 with a fixed resistor to get the machine running without SPI                                                             
      287 +complexity. Once the analog dynamics work, substitute pots.                                                                                   
      288 +                                                                                                                                              
      289 +```                                                                                                                                           
      290 +SPIN_OUT_i ──── 22kΩ ──── integrator (−) input of node j                                                                                      
      291 +SPIN_OUT_j ──── 22kΩ ──── integrator (−) input of node i                                                                                      
      292 +```                                                                                                                                           
      293 +                                                                                                                                              
      294 +Use 22kΩ for antiferromagnetic coupling (Max-Cut). Use 10kΩ for stronger coupling.                                                            
      295 +                                                                                                                                              
      296 +---                                                                                                                                           
      297 +                                                                                                                                              
      298 +### 2.5 Noise Injection Circuit                                                                                                               
      299 +                                                                                                                                              
      300 +```                                                                                                                                           
      301 +        +12V                                                                                                                                  
      302 +         │                                                                                                                                    
      303 +        100kΩ                                                                                                                                 
      304 +         │                                                                                                                                    
      305 +         ├──── Collector of 2N3904 (left floating / reverse biased)                                                                           
      306 +         │                                                                                                                                    
      307 +        Base ──── GND      ← base shorted to emitter = reverse-biased B-E junction                                                            
      308 +         │                                                                                                                                    
      309 +        Emitter ──── noise output (~5–20mV white noise)                                                                                       
      310 +         │                                                                                                                                    
      311 +        [TL084 unity-gain buffer]  ← pin 3(+), pin 1 out tied to pin 2(-)                                                                     
      312 +         │                                                                                                                                    
      313 +     out ──── 1MΩ ──┬──── 1MΩ ──┬──── 1MΩ ──┬──── ...                                                                                         
      314 +                    │            │             │                                                                                              
      315 +              node0 (−)    node1 (−)    node2 (−)    ← inject into each integrator input                                                      
      316 +```                                                                                                                                           
      317 +                                                                                                                                              
      318 +The 1MΩ resistors keep the noise injection weak (~50× weaker than the signal inputs)                                                          
      319 +while reaching all nodes simultaneously. This gives a shared thermal-like bath.                                                               
      320 +                                                                                                                                              
      321 +To make noise amplitude controllable: insert a voltage divider using a MCP4131 between                                                        
      322 +the buffer output and the injection resistors, and drive that pot from the DAC or Z80.                                                        
      323 +                                                                                                                                              
      324 +---                                                                                                                                           
      325 +                                                                                                                                              
      326 +### 2.6 Protoboard Layout Guide                                                                                                               
      327 +                                                                                                                                              
      328 +Use **Veroboard** (strip board) with the strips running horizontally.                                                                         
      329 +                                                                                                                                              
      330 +```                                                                                                                                           
      331 +Strip board — top view, columns A..Z, rows 1..30                                                                                              
      332 +                                                                                                                                              
      333 +Row  1: +12V bus ─────────────────────────────────────────                                                                                    
      334 +Row  2: GND  bus ─────────────────────────────────────────                                                                                    
      335 +Row  3: -12V bus ─────────────────────────────────────────                                                                                    
      336 +Row  4: +5V  bus ─────────────────────────────────────────                                                                                    
      337 +Row  5: (gap)                                                                                                                                 
      338 +Row  6-9:   TL084 U1 (pins 1-14, straddles gap in centre)                                                                                     
      339 +Row 10-13:  LM339 U2 (comparators)                                                                                                            
      340 +Row 14:     (gap)                                                                                                                             
      341 +Row 15-18:  MCP4131 U3 (coupling 0-1)                                                                                                         
      342 +Row 19-22:  MCP4131 U4 (coupling 0-2)                                                                                                         
      343 +Row 23-26:  MCP4131 U5 (coupling 0-3)                                                                                                         
      344 +Row 27-30:  MCP4131 U6 (coupling 1-2)                                                                                                         
      345 +            (continue on second board for U7, U8, U9...)                                                                                      
      346 +```                                                                                                                                           
      347 +                                                                                                                                              
      348 +**Strip cuts required:** Cut each strip under every IC pin that connects to a                                                                 
      349 +different net. Use a 3mm drill bit or track cutter. Mark cuts with a marker before                                                            
      350 +drilling.                                                                                                                                     
      351 +                                                                                                                                              
      352 +**Build order:**                                                                                                                              
      353 +1. Install and test the power rails (measure voltages before inserting any ICs)                                                               
      354 +2. Install TL084 — wire one integrator node, test with a bench signal                                                                         
      355 +3. Install LM339 — wire one comparator, verify ±12V switching                                                                                 
      356 +4. Connect one coupling resistor between node 0 and node 1                                                                                    
      357 +5. Apply power — the two nodes should oscillate and then settle to opposite states                                                            
      358 +6. Replace fixed coupling resistors with MCP4131 pots one at a time                                                                           
      359 +7. Add the noise injection circuit last                                                                                                       
      360 +                                                                                                                                              
      361 +---                                                                                                                                           
      362 +                                                                                                                                              
      363 +### 2.7 Testing Without a Z80                                                                                                                 
      364 +                                                                                                                                              
      365 +Before connecting any digital control, verify the analog behaviour with a multimeter                                                          
      366 +and oscilloscope (or even just LEDs):                                                                                                         
      367 +                                                                                                                                              
      368 +```                                                                                                                                           
      369 +Test 1 — Single node self-oscillation                                                                                                         
      370 +  Wire one integrator with no input coupling. Apply power.                                                                                    
      371 +  The node should sit at +12V or -12V (bistable). Tap the output briefly to GND —                                                             
      372 +  it should flip to the other state and stay there.                                                                                           
      373 +                                                                                                                                              
      374 +Test 2 — Two coupled nodes (antiferromagnetic)                                                                                                
      375 +  Connect two nodes via a 22kΩ resistor (each driving the other's input).                                                                     
      376 +  Apply power. The nodes should snap to OPPOSITE states: (+12V, -12V).                                                                        
      377 +  If they snap to the SAME state, the coupling polarity is inverted — swap                                                                    
      378 +  the resistor connection from the (+) input to the (-) input.                                                                                
      379 +                                                                                                                                              
      380 +Test 3 — Two coupled nodes (ferromagnetic)                                                                                                    
      381 +  Connect via a 22kΩ to the (+) input instead. Nodes should snap to SAME state.                                                               
      382 +                                                                                                                                              
      383 +Test 4 — Four fully connected antiferromagnetic nodes (Max-Cut)                                                                               
      384 +  Connect all 6 pairs via 22kΩ. Apply power. One of the two valid Max-Cut                                                                     
      385 +  solutions should appear: (+-+- or -+-+). Run several power cycles — you                                                                     
      386 +  should see different valid solutions each time (random initial conditions).                                                                 
      387 +```                                                                                                                                           
      388 +                                                                                                                                              
      389 +**LED indicators:** Wire a red LED + 1kΩ from each SPIN_OUT to GND. LED on = +12V                                                             
      390 += spin +1. Easy to read the solution state at a glance without a meter.                                                                       
      391 +                                                                                                                                              
      392 +---                                                                                                                                           
      393 +                                                                                                                                              
      394 +### 2.8 Z80 SPI Port Map                                                                                                                      
      395 +                                                                                                                                              
      396 +Once the analog board is verified, connect to the TEC-1 via the expansion port.                                                               
      397 +                                                                                                                                              
      398 +```                                                                                                                                           
      399 +Port $10  — SPI data byte (MOSI write / MISO read via bit-bang)                                                                               
      400 +Port $11  — SPI clock + CS control register                                                                                                   
      401 +Port $12  — Chip select lines  bit0=ADC_CS  bit1=DAC_CS  bit2=POT_CS                                                                          
      402 +Port $13  — Reset pulse (any OUT to this port triggers reset)                                                                                 
      403 +```                                                                                                                                           
      404 +                                                                                                                                              
      405 +Connect to the TEC-1 I/O expansion connector. The TEC-1 exposes the Z80 data bus,                                                             
      406 +address bus, /IORQ, /RD, /WR lines. Decode ports $10–$13 with a 74HC138 3-to-8                                                                
      407 +decoder:                                                                                                                                      
      408 +                                                                                                                                              
      409 +```                                                                                                                                           
      410 +A3 A2 A1 A0 → 74HC138 select → /CS for port latches (74HC374 or 74HC595)                                                                      
      411 +/IORQ + /WR  → 74HC138 enable                                                                                                                 
      412 +```                                                                                                                                           
      413 +                                                                                                                                              
      414 +If you only need SPI (no parallel bus), a single **74HC595** shift register driven by                                                         
      415 +two Z80 port bits (data + clock) is the simplest interface.                                                                                   
      416 +                                                                                                                                              
      417 +---                                                                                                                                           
      418 +                                                                                                                                              
      419 +## Part 3 — GPIO Interfacing                                                                                                                  
      420 +                                                                                                                                              
      421 +This section covers connecting the analog Ising board to GPIO-capable hosts: a                                                                
      422 +Raspberry Pi (runs `ising_sim.m`), Arduino (stand-alone monitoring), or directly back                                                         
      423 +to the TEC-1 Z80.                                                                                                                             
      424 +                                                                                                                                              
      425 +The key challenge is **voltage level translation**: the analog board operates at                                                              
      426 +**±12V**, GPIO pins expect **0–3.3V or 0–5V**.                                                                                                
      427 +                                                                                                                                              
      428 +---                                                                                                                                           
      429 +                                                                                                                                              
      430 +### 3.1 Spin Output → GPIO Input (±12V to 3.3V/5V)                                                                                            
      431 +                                                                                                                                              
      432 +Each spin output swings between approximately +12V and −12V (or 0V depending on                                                               
      433 +comparator pull-up wiring). This must be clamped to safe GPIO levels.                                                                         
      434 +                                                                                                                                              
      435 +#### Method A — Resistor divider + Schottky clamp (simplest)                                                                                  
      436 +                                                                                                                                              
      437 +Use this when spin output swings 0V to +12V (single-supply comparator with pull-up):                                                          
      438 +                                                                                                                                              
      439 +```                                                                                                                                           
      440 +SPIN_OUT (+12V or 0V)                                                                                                                         
      441 +     │                                                                                                                                        
      442 +    47kΩ                                                                                                                                      
      443 +     │                                                                                                                                        
      444 +     ├──────── GPIO_IN (3.3V pin)                                                                                                             
      445 +     │                                                                                                                                        
      446 +    22kΩ                                                                                                                                      
      447 +     │                                                                                                                                        
      448 +    GND                                                                                                                                       
      449 +                                                                                                                                              
      450 +Divider ratio: 22/(47+22) = 0.32 → 12V × 0.32 = 3.84V → slightly over 3.3V                                                                    
      451 +Add a BAT85 Schottky diode from GPIO_IN to 3.3V rail (cathode to rail) to clamp.                                                              
      452 +```                                                                                                                                           
      453 +                                                                                                                                              
      454 +For a ±12V swing (true bipolar), add a second clamp diode to GND:                                                                             
      455 +                                                                                                                                              
      456 +```                                                                                                                                           
      457 +SPIN_OUT (±12V)                                                                                                                               
      458 +     │                                                                                                                                        
      459 +    100kΩ                                                                                                                                     
      460 +     │                                                                                                                                        
      461 +     ├──── BAT85 anode → cathode to 3.3V   ← clamps positive rail                                                                             
      462 +     │                                                                                                                                        
      463 +     ├──── BAT85 cathode → anode to GND    ← clamps below 0V                                                                                  
      464 +     │                                                                                                                                        
      465 +    GPIO_IN                                                                                                                                   
      466 +                                                                                                                                              
      467 +The 100kΩ limits current through the clamp diodes to safe levels.                                                                             
      468 +Safe for Raspberry Pi GPIO (max ±0.5V beyond rail).                                                                                           
      469 +```                                                                                                                                           
      470 +                                                                                                                                              
      471 +#### Method B — Dedicated level shifter IC (cleanest)                                                                                         
      472 +                                                                                                                                              
      473 +Use a **TXS0108E** (8-channel bidirectional) or **74AHCT125** (unidirectional, 5V→3.3V).                                                      
      474 +                                                                                                                                              
      475 +```                                                                                                                                           
      476 +SPIN_OUT (0–5V only!) ──── 74AHCT125 input ──── GPIO_IN (3.3V)                                                                                
      477 +                            OE tied LOW                                                                                                       
      478 +                            VCC = 3.3V                                                                                                        
      479 +                                                                                                                                              
      480 +Note: 74AHCT125 is unidirectional. For ±12V inputs, use the resistor+clamp                                                                    
      481 +method first to bring signals to 0–5V, then use this for 5V→3.3V conversion.                                                                  
      482 +```                                                                                                                                           
      483 +                                                                                                                                              
      484 +#### Method C — Optocoupler (complete galvanic isolation, recommended for safety)                                                             
      485 +                                                                                                                                              
      486 +```                                                                                                                                           
      487 +SPIN_OUT (+12V / 0V)                                                                                                                          
      488 +     │                                                                                                                                        
      489 +    1kΩ                                                                                                                                       
      490 +     │                                                                                                                                        
      491 +   PC817 LED anode ──── PC817 LED cathode ──── GND (analog)                                                                                   
      492 +                                                                                                                                              
      493 +   PC817 collector ──── 10kΩ ──── +3.3V (RPi)                                                                                                 
      494 +   PC817 emitter   ──── GPIO_IN (RPi) ──── GND (RPi)                                                                                          
      495 +                                                                                                                                              
      496 +Logic: SPIN=+12V → LED on → transistor on → GPIO pulled LOW (inverted)                                                                        
      497 +       SPIN=0V   → LED off → transistor off → GPIO pulled HIGH                                                                                
      498 +```                                                                                                                                           
      499 +                                                                                                                                              
      500 +Use optocouplers when the analog board has a separate GND from the RPi/Z80.                                                                   
      501 +Prevents ground loops and protects the Pi from any fault on the analog side.                                                                  
      502 +                                                                                                                                              
      503 +---                                                                                                                                           
      504 +                                                                                                                                              
      505 +### 3.2 GPIO Output → Analog Board Control (3.3V to ±12V)                                                                                     
      506 +                                                                                                                                              
      507 +To drive the analog reset line or inject a simple bias from GPIO, the 3.3V GPIO                                                               
      508 +signal must be level-shifted up.                                                                                                              
      509 +                                                                                                                                              
      510 +#### Method A — N-channel MOSFET switch (for reset pulse)                                                                                     
      511 +                                                                                                                                              
      512 +```                                                                                                                                           
      513 +GPIO_OUT (3.3V logic) ──── 10kΩ ──── Gate of 2N7000 or BS170                                                                                  
      514 +                                      Source ──── GND (analog board)                                                                          
      515 +                                      Drain ──── Reset line (pulled to +12V via 10kΩ)                                                         
      516 +                                                                                                                                              
      517 +GPIO HIGH → MOSFET on → Reset line pulled LOW → triggers reset                                                                                
      518 +GPIO LOW  → MOSFET off → Reset line at +12V (inactive)                                                                                        
      519 +```                                                                                                                                           
      520 +                                                                                                                                              
      521 +#### Method B — Op-amp level shifter (for analog bias voltages)                                                                               
      522 +                                                                                                                                              
      523 +To output an analog voltage from the RPi's PWM (or a small DAC) to the ±12V domain:                                                           
      524 +                                                                                                                                              
      525 +```                                                                                                                                           
      526 +RPi PWM output ──── RC filter (10kΩ + 10µF) ──── smoothed DC 0–3.3V                                                                           
      527 +                                                      │                                                                                       
      528 +                                               TL071 non-inverting amp                                                                        
      529 +                                               Gain = (R2/R1 + 1) = (47k/10k + 1) = 5.7×                                                      
      530 +                                               Output = 0–18.8V... too high.                                                                  
      531 +                                                                                                                                              
      532 +Better: use a difference amplifier to map 0–3.3V → -12V to +12V:                                                                              
      533 +    Vout = (Vin - 1.65) × (12/1.65) ≈ Vin × 7.27 - 12                                                                                         
      534 +    Set R1=R2=10kΩ, R3=R4=68kΩ and reference = 1.65V (from divider on +3.3V)                                                                  
      535 +```                                                                                                                                           
      536 +                                                                                                                                              
      537 +For most builds, just use the **MCP4921 DAC** (driven by SPI from RPi or Z80) for                                                             
      538 +bias control. It takes 5V supply and outputs 0–5V, then use the op-amp shifter above                                                          
      539 +to stretch to ±12V.                                                                                                                           
      540 +                                                                                                                                              
      541 +---                                                                                                                                           
      542 +                                                                                                                                              
      543 +### 3.3 Raspberry Pi SPI Wiring to the Board                                                                                                  
      544 +                                                                                                                                              
      545 +The MCP3008, MCP4921, and MCP4131 all use SPI (mode 0,0 — CPOL=0, CPHA=0). Wire                                                               
      546 +them to the RPi hardware SPI pins for best performance:                                                                                       
      547 +                                                                                                                                              
      548 +```                                                                                                                                           
      549 +Raspberry Pi (BCM pin numbers)       Analog Board                                                                                             
      550 +                                                                                                                                              
      551 +Pin 19  GPIO10  MOSI  ──────────────  MOSI (all SPI devices in parallel)                                                                      
      552 +Pin 21  GPIO9   MISO  ──────────────  MISO (all SPI devices in parallel)                                                                      
      553 +Pin 23  GPIO11  SCLK  ──────────────  SCLK (all SPI devices in parallel)                                                                      
      554 +                                                                                                                                              
      555 +Pin 24  GPIO8   CE0   ──────────────  CS of MCP3008  (ADC)                                                                                    
      556 +Pin 26  GPIO7   CE1   ──────────────  CS of MCP4921  (DAC)                                                                                    
      557 +Pin 22  GPIO25  (GPIO)─────────────  CS of MCP4131  (coupling pots, shared bus)                                                               
      558 +Pin 18  GPIO24  (GPIO)─────────────  Reset line (via MOSFET, see 3.2A)                                                                        
      559 +                                                                                                                                              
      560 +Pin 2   5V      ──────────────────── VDD of all SPI chips + 7805 input                                                                        
      561 +Pin 6   GND     ──────────────────── GND (digital side only — see note below)                                                                 
      562 +```                                                                                                                                           
      563 +                                                                                                                                              
      564 +> **Important — ground isolation:** The RPi GND and analog board GND should share                                                             
      565 +> one connection point only (star ground topology). Connect them at the power supply                                                          
      566 +> negative terminal, not at the protoboard. This prevents digital switching noise                                                             
      567 +> on the RPi from coupling into the sensitive analog integrators.                                                                             
      568 +                                                                                                                                              
      569 +**SPI chip supply voltage note:**                                                                                                             
      570 +- MCP3008: operates at 2.7V–5.5V. At 5V VDD, MISO output is 5V logic.                                                                         
      571 +  Use a resistor divider (3.3kΩ + 1.8kΩ) on MISO before the RPi pin to                                                                        
      572 +  bring 5V → 3.3V, or power the chip from the RPi 3.3V pin instead.                                                                           
      573 +- MCP4921 and MCP4131: same range, same consideration.                                                                                        
      574 +- **Easiest fix:** power all three SPI chips from RPi pin 1 (3.3V, 50mA max).                                                                 
      575 +  Current draw for all three is under 10mA total.                                                                                             
      576 +                                                                                                                                              
      577 +---                                                                                                                                           
      578 +                                                                                                                                              
      579 +### 3.4 Raspberry Pi GPIO to Spin Output Wiring (8 spins)                                                                                     
      580 +                                                                                                                                              
      581 +This is the path that lets `ising_sim.m` output solved spin states to the GPIO pins,                                                          
      582 +which can then drive LEDs or be read by the TEC-1 as a result register.                                                                       
      583 +                                                                                                                                              
      584 +```                                                                                                                                           
      585 +Raspberry Pi                             LED indicators (optional)                                                                            
      586 +                                                                                                                                              
      587 +Pin 11  GPIO17  ── 330Ω ── LED0 ── GND    Spin 0                                                                                              
      588 +Pin 13  GPIO27  ── 330Ω ── LED1 ── GND    Spin 1                                                                                              
      589 +Pin 15  GPIO22  ── 330Ω ── LED2 ── GND    Spin 2                                                                                              
      590 +Pin 16  GPIO23  ── 330Ω ── LED3 ── GND    Spin 3                                                                                              
      591 +Pin 18  GPIO24  ── 330Ω ── LED4 ── GND    Spin 4                                                                                              
      592 +Pin 22  GPIO25  ── 330Ω ── LED5 ── GND    Spin 5                                                                                              
      593 +Pin 29  GPIO5   ── 330Ω ── LED6 ── GND    Spin 6                                                                                              
      594 +Pin 31  GPIO6   ── 330Ω ── LED7 ── GND    Spin 7                                                                                              
      595 +                                                                                                                                              
      596 +LED on = spin +1 (solution group A)                                                                                                           
      597 +LED off = spin −1 (solution group B)                                                                                                          
      598 +```                                                                                                                                           
      599 +                                                                                                                                              
      600 +To feed these back to the TEC-1 Z80 as an input port, connect all 8 lines through                                                             
      601 +a **74HC245** bus buffer to the Z80 data bus, decoded to an input port address                                                                
      602 +($10 in the MINT driver). The Z80 then reads the spin solution just as it would from                                                          
      603 +the physical ADC.                                                                                                                             
      604 +                                                                                                                                              
      605 +---                                                                                                                                           
      606 +                                                                                                                                              
      607 +### 3.5 Complete Wiring Summary Diagram                                                                                                       
      608 +                                                                                                                                              
      609 +```                                                                                                                                           
      610 +                    ┌──────────────────────────────────┐                                                                                      
      611 +  Raspberry Pi      │     Analog Ising Board           │                                                                                      
      612 +  (or TEC-1 Z80)    │                                  │                                                                                      
      613 +                    │  ┌────────┐   ┌────────┐         │                                                                                      
      614 +  MOSI ─────────────┼──┤MCP4131 ├───┤ TL084  ├─ SPIN0 ─┼── LED0                                                                               
      615 +  MISO ─────────────┼──┤  POT   │   │  INT   │         │                                                                                      
      616 +  SCLK ─────────────┼──┤  SPI   │   │  NODE  ├─ SPIN1 ─┼── LED1                                                                               
      617 +  CS_POT ───────────┼──┤(×6/28) ├───┤  ×4/8  │         │                                                                                      
      618 +                    │  └────────┘   └───┬────┘         │                                                                                      
      619 +  CS_ADC ───────────┼──┐               │               │                                                                                      
      620 +                    │  │  ┌────────┐   │ ┌────────┐    │                                                                                      
      621 +  CS_DAC ───────────┼──┼──┤MCP4921 ├───┴─┤ LM339  │    │                                                                                      
      622 +                    │  │  │  DAC   │     │  COMP  │    │                                                                                      
      623 +  RESET ────────────┼──┼──┤  bias  │     │  ×4/8  │    │                                                                                      
      624 +  (via MOSFET)      │  │  └────────┘     └────────┘    │                                                                                      
      625 +                    │  │                               │                                                                                      
      626 +                    │  └──┤MCP3008 ├── reads SPIN0-7 ──┘                                                                                      
      627 +                    │     │  ADC   │                                                                                                          
      628 +                    │     └────────┘                                                                                                          
      629 +                    │                                  │                                                                                      
      630 +                    │  [2N3904 noise] → [TL084 buf]    │                                                                                      
      631 +                    │       → 1MΩ to each node (−) in  │                                                                                      
      632 +                    │                                  │                                                                                      
      633 +                    │  Power: ±12V analog, +5V digital │                                                                                      
      634 +                    └──────────────────────────────────┘                                                                                      
      635 +                                                                                                                                              
      636 +  GPIO17-24 ── (output) ── LEDs showing solved spin states                                                                                    
      637 +  GPIO17-24 ── (output) ── 74HC245 ── Z80 data bus (TEC-1 input port)                                                                         
      638 +```                                                                                                                                           
      639 +                                                                                                                                              
      640 +---                                                                                                                                           
      641 +                                                                                                                                              
      642 +### 3.6 Enabling GPIO in `ising_sim.m`                                                                                                        
      643 +                                                                                                                                              
      644 +Edit the top of the file:                                                                                                                     
      645 +                                                                                                                                              
      646 +```octave                                                                                                                                     
      647 +use_gpio   = true;        % enable sysfs GPIO                                                                                                 
      648 +GPIO_PINS  = [17 27 22 23 24 25 5 6];  % BCM pin numbers, one per spin                                                                        
      649 +```                                                                                                                                           
      650 +                                                                                                                                              
      651 +Run with permission:                                                                                                                          
      652 +                                                                                                                                              
      653 +```bash                                                                                                                                       
      654 +# Option 1: run as root                                                                                                                       
      655 +sudo octave ising_sim.m                                                                                                                       
      656 +                                                                                                                                              
      657 +# Option 2: add user to gpio group (persistent, preferred)                                                                                    
      658 +sudo usermod -aG gpio $USER                                                                                                                   
      659 +newgrp gpio                                                                                                                                   
      660 +octave ising_sim.m                                                                                                                            
      661 +```                                                                                                                                           
      662 +                                                                                                                                              
      663 +After pressing `s` to solve, the GPIO pins update once per solve with the final                                                               
      664 +binarised spin state. The LED bar shows the solution visually at the same time as                                                             
      665 +the on-screen plot updates.                                                                                                                   
      666 +                                                                                                                                              
      667 +---                                                                                                                                           
      668 +                                                                                                                                              
      669  ### Z80 SPI port map
      670   
      671  ```

❯ /btw also add a part on erxpanding the theory of how and why this all works and what to look for to in order to imporve it. also add some diagnostic and      
falu;t finding using digital prpbes and cro                                                                                                                     

● Read 2 files (ctrl+o to expand)                         
                                                                                          
● Good — now adding the theory section and the CRO/probe diagnostics. Let me append both to the end of the file before the file structure section:
                                                                                                                                                                
● Read 1 file (ctrl+o to expand)                                                          
                                                                                                                                                                
● Update(cmim-sim/HOW-TO.md)                                                                                                                                    
  ⎿  Added 392 lines                                                                                                                                            
       861                                                                                                                                                      
       862  ---                                                                                                                                                 
       863                                                                                                                                                      
       864 +## Part 7 — Theory: Why and How This Actually Works                                                                                                 
       865 +                                                                                                                                                    
       866 +Understanding the physics lets you predict behaviour, diagnose faults, and know which                                                               
       867 +direction to push improvements.                                                                                                              
       868 +                                                                                                                                             
       869 +---                                                                                                                                          
       870 +                                                                                                                                             
       871 +### 7.1 The Ising Model                                                                                                                      
       872 +                                                                                                                                             
       873 +The Ising model was originally a statistical physics model of ferromagnetism. Each                                                           
       874 +atom has a magnetic **spin** that can point either up (+1) or down (−1). Neighbouring                                                        
       875 +spins interact, and the whole system settles into the lowest-energy configuration.                                                           
       876 +                                                                                                                                             
       877 +The **Hamiltonian** (energy function) is:                                                                                                    
       878 +                                                                                                                                             
       879 +```                                                                                                                                          
       880 +E = − Σ(i<j) Jij · si · sj  −  Σi hi · si                                                                                                    
       881 +                                                                                                                                             
       882 +where:                                                                                                                                       
       883 +  si    = spin of node i  (+1 or -1)                                                                                                         
       884 +  Jij   = coupling strength between nodes i and j                                                                                            
       885 +  hi    = external bias (magnetic field) on node i                                                                                           
       886 +```                                                                                                                                          
       887 +                                                                                                                                             
       888 +The machine tries to minimise E. The coupling signs determine behaviour:                                                                     
       889 +                                                                                                                                             
       890 +```                                                                                                                                          
       891 +Jij > 0  (ferromagnetic)   → si and sj want to be the SAME sign                                                                              
       892 +Jij < 0  (antiferromagnetic) → si and sj want to be OPPOSITE signs                                                                           
       893 +```                                                                                                                                          
       894 +                                                                                                                                             
       895 +Many hard optimisation problems can be cast into this form by choosing J and h                                                               
       896 +appropriately. When physics minimises E, it simultaneously solves the problem.                                                               
       897 +                                                                                                                                             
       898 +---                                                                                                                                          
       899 +                                                                                                                                             
       900 +### 7.2 Why Op-Amps Implement This Naturally                                                                                                 
       901 +                                                                                                                                             
       902 +An op-amp integrator accumulates the weighted sum of its inputs over time:                                                                   
       903 +                                                                                                                                             
       904 +```                                                                                                                                          
       905 +tau · dVout/dt = −Vout + Σj (Jij · Vj) + hi                                                                                                  
       906 +```                                                                                                                                          
       907 +                                                                                                                                             
       908 +This is **exactly the gradient descent on the Ising energy**. Each node's voltage                                                            
       909 +moves in the direction that reduces the total energy. When all nodes stop changing,                                                          
       910 +you are at a (local) energy minimum — a candidate solution.                                                                                  
       911 +                                                                                                                                             
       912 +The **comparator / Schmitt trigger** at the output forces the continuous voltage to                                                          
       913 +snap to +Vsat or −Vsat, producing a hard binary spin. This is the binarisation step.                                                         
       914 +                                                                                                                                             
       915 +The **tanh** version (used in the simulation) keeps a soft output during settling,                                                           
       916 +which gives smoother energy landscapes and avoids hard traps. The Schmitt version is                                                         
       917 +faster and simpler to build but more prone to local minima.                                                                                  
       918 +                                                                                                                                             
       919 +```                                                                                                                                          
       920 +Continuous relaxation (tanh):          Bistable snap (Schmitt):                                                                              
       921 +                                                                                                                                             
       922 +Vout                                   Vout                                                                                                  
       923 +  │      ╭──────                         │         ┌──────                                                                                   
       924 +  │   ╭──╯                               │         │                                                                                         
       925 +  │───╯                                  │─────────┘                                                                                         
       926 +  │                  time                │              time                                                                                 
       927 +  └──────────────────                    └──────────────────                                                                                 
       928 +                                                                                                                                             
       929 +Settles gradually, escapes          Snaps fast, but can lock                                                                                 
       930 +local traps via noise               into local minima easily                                                                                 
       931 +```                                                                                                                                          
       932 +                                                                                                                                             
       933 +---                                                                                                                                          
       934 +                                                                                                                                             
       935 +### 7.3 The Role of Noise                                                                                                                    
       936 +                                                                                                                                             
       937 +Without noise, the system always settles to the **nearest local minimum** from the                                                           
       938 +starting conditions. This may not be the global minimum (best solution).                                                                     
       939 +                                                                                                                                             
       940 +Noise acts like **temperature** in simulated annealing:                                                                                      
       941 +                                                                                                                                             
       942 +- High noise = high temperature → system explores widely, escapes traps                                                                      
       943 +- Low noise = low temperature → system settles into the nearest minimum                                                                      
       944 +                                                                                                                                             
       945 +The annealing schedule — starting hot and cooling gradually — gives the system time                                                          
       946 +to find the global minimum before committing.                                                                                                
       947 +                                                                                                                                             
       948 +In the hardware, noise comes from the **reverse-biased transistor junction**: shot                                                           
       949 +noise in a reverse-biased B-E junction is broadband white noise, easily amplified to                                                         
       950 +the ~10–50mV range needed.                                                                                                                   
       951 +                                                                                                                                             
       952 +---                                                                                                                                          
       953 +                                                                                                                                             
       954 +### 7.4 The Coupling Matrix as a Problem Encoder                                                                                             
       955 +                                                                                                                                             
       956 +The coupling matrix J completely defines what problem the machine is solving.                                                                
       957 +Changing J reprograms the machine with a new problem.                                                                                        
       958 +                                                                                                                                             
       959 +**Max-Cut encoding:**                                                                                                                        
       960 +                                                                                                                                             
       961 +```                                                                                                                                          
       962 +Graph:  A──B──C──D──A  (ring of 4)                                                                                                           
       963 +             │                                                                                                                               
       964 +         each edge → Jij = −1  (antiferromagnetic)                                                                                           
       965 +                                                                                                                                             
       966 +The machine minimises E = −Σ Jij·si·sj = +Σ si·sj (for negative Jij)                                                                         
       967 +i.e. it MAXIMISES disagreement = maximises the number of cut edges.                                                                          
       968 +```                                                                                                                                          
       969 +                                                                                                                                             
       970 +**Frustration** — when no assignment of spins can satisfy all couplings simultaneously                                                       
       971 +(e.g. a triangle with all antiferromagnetic couplings), the machine settles to the                                                           
       972 +best compromise. This is where multiple runs and statistics are needed.                                                                      
       973 +                                                                                                                                             
       974 +---                                                                                                                                          
       975 +                                                                                                                                             
       976 +### 7.5 What to Look For to Improve Performance                                                                                              
       977 +                                                                                                                                             
       978 +#### Problem: too many wrong answers                                                                                                         
       979 +                                                                                                                                             
       980 +Root cause: noise too low (system snaps before exploring), or annealing too fast.                                                            
       981 +                                                                                                                                             
       982 +Fixes:                                                                                                                                       
       983 +- Increase noise amplitude (raise pot on noise injection circuit)                                                                            
       984 +- Slow the annealing schedule (`anneal_rate` closer to 1.0 in simulation)                                                                    
       985 +- Run multiple shots and take lowest-energy result (multi-shot in MINT: word `Z`)                                                            
       986 +- Add a periodic global kick: briefly short all integrator capacitors to GND via                                                             
       987 +  a relay or CD4066 switch (controlled by Z80), then release — forces re-exploration                                                         
       988 +                                                                                                                                             
       989 +#### Problem: same wrong answer every time                                                                                                   
       990 +                                                                                                                                             
       991 +Root cause: deep local minimum — the initial conditions always lead there.                                                                   
       992 +                                                                                                                                             
       993 +Fixes:                                                                                                                                       
       994 +- Use **random initial conditions**: before each run, inject a brief burst of high                                                           
       995 +  noise to scramble all nodes, then anneal. MINT word `E` (reset) should also                                                                
       996 +  scramble; if the reset circuit is too slow, add a random DAC bias burst.                                                                   
       997 +- Add a correction feedback step (digital): after convergence, compute energy in                                                             
       998 +  MINT, compare to best known, if worse add a small bias to the most suspicious                                                              
       999 +  node and re-run.                                                                                                                           
      1000 +                                                                                                                                             
      1001 +#### Problem: settling time too long                                                                                                         
      1002 +                                                                                                                                             
      1003 +Root cause: RC time constant too large or coupling resistors too high.                                                                       
      1004 +                                                                                                                                             
      1005 +Fixes:                                                                                                                                       
      1006 +- Reduce Cf from 10nF to 4.7nF or 2.2nF (speeds up integrator 2–5×)                                                                          
      1007 +- Reduce coupling resistors from 22kΩ to 10kΩ (stronger coupling = faster pull)                                                              
      1008 +- Reduce Rf from 100kΩ to 47kΩ (but watch for instability / oscillation)                                                                     
      1009 +- Use faster op-amps: OPA2134 or LT1057 instead of TL084                                                                                     
      1010 +                                                                                                                                             
      1011 +#### Problem: poor solution quality on dense graphs                                                                                          
      1012 +                                                                                                                                             
      1013 +Root cause: the all-to-all resistor coupling network has resistive loading effects —                                                         
      1014 +each node's output is shared across many resistors, reducing the effective coupling                                                          
      1015 +strength as N grows.                                                                                                                         
      1016 +                                                                                                                                             
      1017 +Fixes:                                                                                                                                       
      1018 +- Buffer each spin output with a TL074 unity-gain follower before the coupling                                                               
      1019 +  network — the buffer drives the resistors, not the comparator output directly                                                              
      1020 +- Use a lower impedance coupling network (lower resistor values + buffered outputs)                                                          
      1021 +- Switch to time-multiplexed coupling (connect subsets of nodes at a time via                                                                
      1022 +  CD4051 analog mux controlled by Z80) — reduces simultaneous loading                                                                        
      1023 +                                                                                                                                             
      1024 +#### What the energy plot tells you (simulation)                                                                                             
      1025 +                                                                                                                                             
      1026 +```                                                                                                                                          
      1027 +Good solve:                    Bad solve (stuck):                                                                                            
      1028 +E                              E                                                                                                             
      1029 +│╲                             │╲╱╲╱                                                                                                         
      1030 +│ ╲                            │     ╲╱╲╱╲                                                                                                   
      1031 +│  ╲___________                │           ╲╱  (noise, no convergence)                                                                       
      1032 +└──────────────                └─────────────                                                                                                
      1033 +                                                                                                                                             
      1034 +Action: fine                   Action: increase anneal_rate                                                                                  
      1035 +                                       or reduce noise_amp                                                                                   
      1036 +```                                                                                                                                          
      1037 +                                                                                                                                             
      1038 +---                                                                                                                                          
      1039 +                                                                                                                                             
      1040 +## Part 8 — Diagnostics with CRO and Logic Probe                                                                                             
      1041 +                                                                                                                                             
      1042 +This section covers how to systematically fault-find the circuit using a CRO                                                                 
      1043 +(oscilloscope) and a simple 5V logic probe.                                                                                                  
      1044 +                                                                                                                                             
      1045 +---                                                                                                                                          
      1046 +                                                                                                                                             
      1047 +### 8.1 Essential Test Points                                                                                                                
      1048 +                                                                                                                                             
      1049 +Mark these test points on your protoboard before building:                                                                                   
      1050 +                                                                                                                                             
      1051 +```                                                                                                                                          
      1052 +TP1  — +12V rail (check: DC voltage, noise < 50mV)                                                                                           
      1053 +TP2  — −12V rail (check: DC voltage, noise < 50mV)                                                                                           
      1054 +TP3  — +5V rail  (check: DC voltage, ripple < 20mV)                                                                                          
      1055 +TP4  — GND (reference for all measurements)                                                                                                  
      1056 +TP5  — Integrator output of node 0 (V_int0) — key waveform                                                                                   
      1057 +TP6  — Spin output of node 0 (SPIN0) — should be hard +/−12V when settled                                                                    
      1058 +TP7  — Noise source output (after buffer) — should show noise waveform                                                                       
      1059 +TP8  — SPI SCLK line                                                                                                                         
      1060 +TP9  — SPI MOSI line                                                                                                                         
      1061 +TP10 — ADC CS line                                                                                                                           
      1062 +```                                                                                                                                          
      1063 +                                                                                                                                             
      1064 +---                                                                                                                                          
      1065 +                                                                                                                                             
      1066 +### 8.2 Power Rail Checks (Multimeter first, CRO second)                                                                                     
      1067 +                                                                                                                                             
      1068 +Before inserting any ICs:                                                                                                                    
      1069 +                                                                                                                                             
      1070 +```                                                                                                                                          
      1071 +Check        Expected         Fault if not                                                                                                   
      1072 ++12V rail    +11.5 to +12.5V  Supply wiring, regulator fault                                                                                 
      1073 +−12V rail    −11.5 to −12.5V  Dual supply fault, reversed connection                                                                         
      1074 ++5V rail     +4.75 to +5.25V  7805 fault, input undervoltage                                                                                 
      1075 +GND          0V reference     Broken GND connection → everything wrong                                                                       
      1076 +```                                                                                                                                          
      1077 +                                                                                                                                             
      1078 +With CRO on the ±12V rails, look for:                                                                                                        
      1079 +- AC ripple > 100mV peak-peak → insufficient decoupling, add 10µF electrolytic + 100nF ceramic at power entry                                
      1080 +- High-frequency hash (>100kHz) → digital SPI switching coupling into analog rail → add ferrite bead in series with the analog supply line   
      1081 +                                                                                                                                             
      1082 +---                                                                                                                                          
      1083 +                                                                                                                                             
      1084 +### 8.3 Single Node Waveforms (CRO)                                                                                                          
      1085 +                                                                                                                                             
      1086 +#### Test A — Integrator free-running (no coupling inputs, no noise)                                                                         
      1087 +                                                                                                                                             
      1088 +```                                                                                                                                          
      1089 +Expected waveform on V_int (TP5):                                                                                                            
      1090 +  Sits at one of two values: approximately +Vsat or −Vsat of the TL084 (±10–11V)                                                             
      1091 +  Does NOT oscillate unless there is instability.                                                                                            
      1092 +                                                                                                                                             
      1093 +If oscillating:                                                                                                                              
      1094 +  ← Rf too low, or Cf too small → reduce gain, increase Cf                                                                                   
      1095 +  ← Stray positive feedback path → check layout for coupling between output and input                                                        
      1096 +```                                                                                                                                          
      1097 +                                                                                                                                             
      1098 +#### Test B — Integrator with noise injection active                                                                                         
      1099 +                                                                                                                                             
      1100 +```                                                                                                                                          
      1101 +Expected waveform on V_int (TP5), CRO: AC coupled, 20mV/div, 10ms/div:                                                                       
      1102 +  Small noise riding on the DC level (~10–30mV peak-peak)                                                                                    
      1103 +  Occasional random flips between +Vsat and −Vsat                                                                                            
      1104 +                                                                                                                                             
      1105 +If no noise visible:                                                                                                                         
      1106 +  ← 2N3904 noise source not working → check reverse bias on B-E                                                                              
      1107 +  ← Buffer op-amp oscillating at RF → add 100pF from buffer output to −input                                                                 
      1108 +  ← Injection resistors too large → reduce from 1MΩ to 470kΩ                                                                                 
      1109 +                                                                                                                                             
      1110 +If too much noise (nodes switching rapidly):                                                                                                 
      1111 +  ← Injection resistors too small → increase to 2.2MΩ                                                                                        
      1112 +  ← Buffer gain too high → add resistor divider at buffer output                                                                             
      1113 +```                                                                                                                                          
      1114 +                                                                                                                                             
      1115 +#### Test C — SPIN output (TP6)                                                                                                              
      1116 +                                                                                                                                             
      1117 +```                                                                                                                                          
      1118 +Expected waveform: clean ±12V square wave transitions when node flips                                                                        
      1119 +  Rise/fall time: < 1µs (LM339 comparator)                                                                                                   
      1120 +  Final settled state: solid +12V or −12V, no oscillation                                                                                    
      1121 +                                                                                                                                             
      1122 +If intermediate voltage (not rail-to-rail):                                                                                                  
      1123 +  ← Comparator output not saturating → check +12V on LM339 V+ pin                                                                            
      1124 +  ← Pull-up resistor missing or wrong value → check 10kΩ to +12V on open-collector output                                                    
      1125 +  ← LM339 output shorted → check for solder bridges                                                                                          
      1126 +                                                                                                                                             
      1127 +If rapid oscillation at settled state:                                                                                                       
      1128 +  ← Hysteresis resistor missing or wrong value → increase R_hys from 100kΩ to 220kΩ                                                          
      1129 +  ← Output capacitive loading → add 10pF from output to GND to slow the comparator                                                           
      1130 +```                                                                                                                                          
      1131 +                                                                                                                                             
      1132 +---                                                                                                                                          
      1133 +                                                                                                                                             
      1134 +### 8.4 Coupling Network Checks                                                                                                              
      1135 +                                                                                                                                             
      1136 +Probe between two coupled nodes to verify coupling direction.                                                                                
      1137 +                                                                                                                                             
      1138 +**Test procedure:**                                                                                                                          
      1139 +                                                                                                                                             
      1140 +1. Disconnect the noise source (remove the 1MΩ injection resistor temporarily).                                                              
      1141 +2. Force SPIN0 to +12V by connecting its integrator (+) input to +12V briefly.                                                               
      1142 +3. Measure the resulting voltage at the (−) input of node 1's integrator.                                                                    
      1143 +                                                                                                                                             
      1144 +```                                                                                                                                          
      1145 +Expected: a small negative voltage at node 1's (−) input                                                                                     
      1146 +  (negative because SPIN0 is positive, coupled inverted through summing amp)                                                                 
      1147 +                                                                                                                                             
      1148 +If zero: coupling resistor open, MCP4131 not configured (wiper disconnected)                                                                 
      1149 +If positive: coupling polarity inverted — swap P0A and P0B on the MCP4131                                                                    
      1150 +If very large: coupling resistance too low — recheck resistor values                                                                         
      1151 +```                                                                                                                                          
      1152 +                                                                                                                                             
      1153 +**CRO dual-channel coupling test:**                                                                                                          
      1154 +                                                                                                                                             
      1155 +```                                                                                                                                          
      1156 +CH1: SPIN0 output                                                                                                                            
      1157 +CH2: SPIN1 output                                                                                                                            
      1158 +Timebase: 50ms/div                                                                                                                           
      1159 +                                                                                                                                             
      1160 +With antiferromagnetic coupling, when power is applied:                                                                                      
      1161 +  → both channels flip briefly, then one goes to +12V and the other to −12V                                                                  
      1162 +  → they should NOT both sit at the same value                                                                                               
      1163 +                                                                                                                                             
      1164 +If both channels sit at the same value:                                                                                                      
      1165 +  ← Coupling polarity is ferromagnetic (swapped) → reverse coupling resistor connection                                                      
      1166 +  ← One node is dead and the other is dominating → check node separately                                                                     
      1167 +```                                                                                                                                          
      1168 +                                                                                                                                             
      1169 +---                                                                                                                                          
      1170 +                                                                                                                                             
      1171 +### 8.5 SPI Communication Checks (Logic Probe + CRO)                                                                                         
      1172 +                                                                                                                                             
      1173 +Use a logic probe (5V type) on the SPI lines.                                                                                                
      1174 +                                                                                                                                             
      1175 +#### Logic probe spot-checks                                                                                                                 
      1176 +                                                                                                                                             
      1177 +```                                                                                                                                          
      1178 +Line      Expected during SPI transaction   Fault if not                                                                                     
      1179 +SCLK      pulsing (8 pulses per byte)       Port $11 not toggling → check Z80 OUT                                                            
      1180 +MOSI      changing data pattern             Port $10 not loaded → check MINT word A                                                          
      1181 +CS_ADC    pulses LOW during ADC read        Port $12 bit0 not driven → wiring                                                                
      1182 +CS_DAC    pulses LOW during DAC write       Port $12 bit1 not driven → wiring                                                                
      1183 +CS_POT    pulses LOW during pot write       Port $12 bit2 not driven → wiring                                                                
      1184 +MISO      changes during ADC read           ADC not responding → check VDD, GND                                                              
      1185 +```                                                                                                                                          
      1186 +                                                                                                                                             
      1187 +#### CRO SPI waveform (normal)                                                                                                               
      1188 +                                                                                                                                             
      1189 +```                                                                                                                                          
      1190 +SCLK:  ───┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌────   8 clean clock pulses per byte                                                                               
      1191 +          └┘└┘└┘└┘└┘└┘└┘└┘                                                                                                                   
      1192 +                                                                                                                                             
      1193 +MOSI:  ─── D7 D6 D5 D4 D3 D2 D1 D0 ───   stable data on rising edge                                                                          
      1194 +                                                                                                                                             
      1195 +CS:    ─────┐                    ┌─────                                                                                                      
      1196 +            └────────────────────┘       LOW for duration of transfer                                                                        
      1197 +```                                                                                                                                          
      1198 +                                                                                                                                             
      1199 +If SCLK shows ringing or slow edges:                                                                                                         
      1200 +- Add 33Ω series resistor on SCLK line close to source                                                                                       
      1201 +- Shorten the physical wire length                                                                                                           
      1202 +                                                                                                                                             
      1203 +If MISO is not changing during ADC reads:                                                                                                    
      1204 +- Verify ADC VDD connected to 3.3V or 5V                                                                                                     
      1205 +- Verify ADC GND connected                                                                                                                   
      1206 +- Verify SCLK and MOSI are reaching the ADC chip (probe at IC pin, not at far end of wire)                                                   
      1207 +                                                                                                                                             
      1208 +---                                                                                                                                          
      1209 +                                                                                                                                             
      1210 +### 8.6 End-to-End System Check (CRO 4-channel ideal)                                                                                        
      1211 +                                                                                                                                             
      1212 +With 4 CRO channels on the four spin outputs of a 4-node system, apply power and                                                             
      1213 +watch for the settling sequence:                                                                                                             
      1214 +                                                                                                                                             
      1215 +```                                                                                                                                          
      1216 +t=0ms   Power applied                                                                                                                        
      1217 +        All nodes at mid-rail or random state — expect rapid transitions                                                                     
      1218 +                                                                                                                                             
      1219 +t=1-5ms Nodes flip repeatedly as they find equilibrium                                                                                       
      1220 +         Expect: alternating high-low transitions, possibly oscillating                                                                      
      1221 +                                                                                                                                             
      1222 +t=5-20ms System settles                                                                                                                      
      1223 +         Expect: each channel stable at ±12V, no further transitions                                                                         
      1224 +         Valid Max-Cut solution: alternating (+−+−) or (−+−+) pattern                                                                        
      1225 +                                                                                                                                             
      1226 +If settling takes > 100ms:                                                                                                                   
      1227 +  ← RC time constant too large → reduce Cf or coupling resistors                                                                             
      1228 +                                                                                                                                             
      1229 +If system never settles (continuous oscillation after 100ms):                                                                                
      1230 +  ← Noise too high → reduce noise injection                                                                                                  
      1231 +  ← Hysteresis too low → increase R_hys                                                                                                      
      1232 +  ← Coupling too strong and creating limit cycle → increase coupling resistors                                                               
      1233 +                                                                                                                                             
      1234 +If all nodes go to same state (++++):                                                                                                        
      1235 +  ← All couplings are ferromagnetic → check coupling polarity (see 8.4)                                                                      
      1236 +  ← Noise source not working → nodes can't escape dominant state                                                                             
      1237 +```                                                                                                                                          
      1238 +                                                                                                                                             
      1239 +---                                                                                                                                          
      1240 +                                                                                                                                             
      1241 +### 8.7 Quick-Reference Fault Table                                                                                                          
      1242 +                                                                                                                                             
      1243 +| Symptom | Where to probe | Expected signal | Likely fault |                                                                                
      1244 +|---|---|---|---|                                                                                                                            
      1245 +| Node stays at mid-rail ~0V | V_int (TP5) | DC at ±10V settled | Integrator output stage, check TL084 pin 8 (V+) |                          
      1246 +| Node oscillates continuously | V_int + SPIN_OUT | DC after settling | R_hys too small, add/increase hysteresis resistor |                  
      1247 +| No SPI response from ADC | MISO line at ADC pin | Changing data | ADC power or ground missing |                                            
      1248 +| Coupling has no effect | Both spin outputs | Opposite states | Coupling polarity inverted, or MCP4131 wiper not connected |                
      1249 +| Noise always drives same solution | All spin outputs | Random initial flip | Noise injection one-sided — check buffer output can swing     
           +negative |                                                                                                                                   
      1250 +| Digital switching visible on V_int | V_int (AC coupled) | Only thermal noise | Shared GND path — star-ground the analog and digital GND |  
      1251 +| +5V rail < 4.5V | TP3 | +5V stable | 7805 input too low, check input ≥ 7V, or replace with 3.3V LDO |                                      
      1252 +| Op-amp output clipped at ±10V not ±12V | SPIN_OUT | ±12V | Normal for TL084 — Vsat ≈ VCC − 2V, not a fault |                               
      1253 +                                                                                                                                             
      1254 +---                                                                                                                                          
      1255 +                                                                                                                                             
      1256  ## File Structure
      1257   
      1258  ```

● Read 1 file (ctrl+o to expand)                          
                                                                                          
● Done. The manual is now 1,265 lines / 46KB. Here's what was added:
                                                                                                                                                                
  ---                                                                                     
  New in Part 2 (circuit build, massively expanded)                                                                                                             
                                                                                                                                                                
  - 2.1 Full BOM with 4-node prototype separately from 8-node, costs in AUD
  - 2.2 Three power supply options (batteries / bench supply / virtual ground), decoupling rules                                                                
  - 2.3 Full ASCII schematic for a single spin node — integrator stage + comparator stage with hysteresis, exact component values
  - 2.4 How to wire MCP4131 coupling pots, plus a fixed-resistor fallback for getting the analog working before adding SPI complexity
  - 2.5 Noise injection with exact resistor values and layout
  - 2.6 Protoboard layout guide — strip numbering, IC placement, where to cut tracks, step-by-step build order
  - 2.7 Four standalone tests to verify the analog before touching digital control (single node, two coupled nodes, LED indicators)
  - 2.8 Z80 port decoding with 74HC138 + 74HC595 options

  New Part 3 (GPIO interfacing — completely new section)

  - 3.1 Three methods for ±12V → 3.3V: resistor divider+clamp, TXS0108E, and optocoupler (with full circuits)
  - 3.2 Two methods for GPIO → analog board: MOSFET switch for reset, op-amp difference amp for bias
  - 3.3 Full RPi SPI wiring table (BCM pins), voltage compatibility notes, star-ground warning
  - 3.4 RPi GPIO → LED bar + 74HC245 → Z80 data bus wiring
  - 3.5 Complete end-to-end block diagram
  - 3.6 How to enable GPIO in ising_sim.m with permission fix

  New Part 7 (theory)

  Ising Hamiltonian derivation, why op-amp integrators implement gradient descent naturally, tanh vs Schmitt settle curves, noise as temperature / annealing,
  coupling matrix as problem encoder, frustration, and a detailed table of what to change and why for five common failure modes.

  New Part 8 (CRO + logic probe diagnostics)

  - 10 labeled test points to mark on the board
  - Power rail check table (multimeter → CRO)
  - Three CRO waveform tests per node (free-running, noise injection, spin output) with expected vs fault descriptions
  - SPI logic probe checks and CRO waveform description
  - 4-channel settle sequence — exactly what you should see at each time step
  - Quick-reference fault table: 8 symptoms with probe location, expected signal, and likely cause

✻ Worked for 4m 48s                                        


Resume this session with:                                                                                                                                       
claude --resume 00c1afe5-0b43-46df-af4f-adf3c73e88ab  


