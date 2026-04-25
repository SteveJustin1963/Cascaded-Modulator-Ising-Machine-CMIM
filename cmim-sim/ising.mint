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
; Z80 SPI port map (bit-banged):
;   $10  SPI MOSI/MISO data byte (write = MOSI, read = MISO)
;   $11  SPI CLK + CS control:  bit0=CLK  bit1=MOSI  bit2=MISO(in)
;   $12  Chip-select lines:     bit0=ADC  bit1=DAC   bit2=POT
;   $13  Reset (write any)
;
; MINT2 I/O:  n /I  reads port n -> stack
;             n data /O  writes data to port n
;
; Variables (single lowercase):
;   s = spin array  [16 elements, 0=spin-1, 1=spin+1]
;   j = coupling matrix (packed, 16x16 = 256 bytes)
;   b = bias array  [16 elements]
;   n = number of nodes (8 default)
;   t = temp var
;   i,k,m = loop / scratch
; ============================================================

; --- Init arrays -------------------------------------------
:I
  [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] s !
  [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] b !
  [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ] j !
  8 n !
  `ISING INIT OK` /N
;

; --- SPI: send byte on stack, receive byte -> stack ---------
; Uses bit-bang on port $10 (data) + $11 (clk)
; Simple: write byte to $10, toggle $11 8 times, read $10
:A
  $10 " /O          ; write MOSI byte to port $10
  8 ( $11 1 /O $11 0 /O )   ; 8 CLK pulses
  $10 /I            ; read MISO byte
;

; --- ADC: read MCP3008 channel n -> voltage (0-1023) --------
; Stack: n -- val
; MCP3008 SPI: start=1, single=1, channel=D2:D0
:B
  " 6 { 1 | $18 |   ; build config byte: 0x18 | (ch & 7) << 3 ... simplified
  $12 1 /O          ; assert ADC CS (bit0)
  A                 ; send config, receive high nibble
  t !
  0 A               ; send 0, receive low byte
  t 4 { | k !       ; combine 10-bit result
  $12 0 /O          ; deassert CS
  k
;

; Simplified single-channel ADC read (channel on stack)
; Real MCP3008 needs 3-byte SPI exchange:
;   byte1: 0x01 (start)
;   byte2: 0x80|(ch<<4) for single-ended
;   byte3: 0x00
;   result = ((byte2_rx & 0x03)<<8) | byte3_rx
:Q
  " m !             ; save channel
  $12 1 /O          ; ADC CS low
  1 A               ; start bit
  /U                ; drop received byte
  m 4 { $80 | A     ; send channel select, receive high 2 bits
  $03 & t !         ; mask bits 9:8
  0 A               ; clock out low 8 bits
  t 8 { |           ; combine: result = t<<8 | low
  $12 0 /O          ; ADC CS high
;

; --- DAC: write MCP4921 value to channel n -----------------
; Stack: val node --
; MCP4921 16-bit SPI: bit15=0(A) or 1(B), bit14=0(unbuf),
;                     bit13=1(1x), bit12=1(SHDN off), bits11:0=data
:D
  " k !             ; k = node index (used for CS select)
  $FFF & t !        ; t = 12-bit value (mask)
  k 12 { $3000 | t |  ; config: 0x3000 | (node<<12) | val... simplified
  ; Note: MCP4921 is single-channel; use MCP4922 for dual
  $12 2 /O          ; DAC CS low
  " 8 { A           ; send high byte
  /U
  $FF & A           ; send low byte
  /U
  $12 0 /O          ; DAC CS high
;

; --- POT: write MCP4131 coupling weight --------------------
; Stack: weight i j --
; Coupling index = i*16+j (row-major into j array)
; MCP4131 SPI: 2 bytes: cmd=0x00 (write wiper), data=0-128
:C
  " " n * + k !     ; k = i*n + j (flat index)
  " j k ?!          ; store in coupling array: j[k] = weight
  ; write to physical digital pot (pot# = k, value = weight)
  $12 4 /O          ; POT CS low
  $00 A /U          ; cmd byte = write wiper
  A /U              ; data byte = weight (0-128 = 0-10kohm)
  $12 0 /O          ; POT CS high
;

; --- RESET: pulse reset line -------------------------------
:E
  $13 1 /O          ; strobe reset port
  100 ( )           ; short delay
  $13 0 /O
  `RST` /N
;

; --- WAIT: busy-wait delay (units ~= 100us each) -----------
; Stack: n --
:W
  ( 255 ( ) )       ; outer n * inner 255 nops
;

; --- READ all 8 (or n) spins from ADC -> s array -----------
:R
  n ( /i Q s /i ?! )
;

; --- SHOW spin states --------------------------------------
:H
  `SPINS: `
  n (
    s /i ? t !
    t 512 > ( 43 /C ) /E ( 45 /C )   ; '+' if >512, '-' if <=512
    32 /C
  )
  /N
;

; --- SHOW numeric spin values ------------------------------
:V
  `RAW: `
  n ( s /i ? . 32 /C )
  /N
;

; --- SET Max-Cut graph (4-node fully connected) ------------
; All couplings = 64 (mid-value = antiferromagnetic)
:P
  4 n !
  64 0 1 C   ; J[0][1] = 64
  64 0 2 C
  64 0 3 C
  64 1 2 C
  64 1 3 C
  64 2 3 C
  `MAX-CUT 4-NODE SET` /N
;

; --- SET 8-node ring graph ---------------------------------
:X
  8 n !
  64 0 1 C
  64 1 2 C
  64 2 3 C
  64 3 4 C
  64 4 5 C
  64 5 6 C
  64 6 7 C
  64 7 0 C
  `RING-8 SET` /N
;

; --- SOLVE: reset and wait for settling --------------------
:S
  E
  200 W
  R
;

; --- ENERGY: compute Ising energy from current spins -------
; E = -sum(J[i][j]*s[i]*s[j]) simplified to sign comparison
; Returns relative energy (lower = better solution)
:G
  0 t !
  n (
    n (
      ; s[i]>512 = +1, else -1; s[j]>512 = +1, else -1
      ; same sign -> contribution = -J[i][j]
      ; diff sign -> contribution = +J[i][j]
      s /i ? 512 > k !
      ; NOTE: /i is outer loop, but MINT only has one /i
      ; For 2D energy, run as two separate loops in real code
    )
  )
  `ENERGY: ` t . /N
;

; --- Main interactive loop ---------------------------------
; Commands: S=solve  H=show spins  V=verbose  P=maxcut
;           X=ring8  I=init  R=read  E=reset  Q=quit
:M
  I
  `ISING MACHINE CONTROLLER` /N
  `S=solve H=show P=maxcut X=ring8 Q=quit` /N
  /T (                  ; loop forever
    `> ` /K k !         ; read key
    k 83 = ( S H )      ; S -> solve + show
    k 72 = ( H )        ; H -> show spins
    k 86 = ( V )        ; V -> verbose values
    k 80 = ( P S H )    ; P -> set maxcut + solve + show
    k 88 = ( X S H )    ; X -> set ring + solve + show
    k 73 = ( I )        ; I -> init
    k 82 = ( R H )      ; R -> read spins + show
    k 69 = ( E )        ; E -> hardware reset
    k 81 = ( /F )       ; Q -> quit (/F = exit in MINT2... actually
                        ;   use: 1 k ! to break, see below)
  )
;
