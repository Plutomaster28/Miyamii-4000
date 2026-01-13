# Quick Start Guide - Miyamii-4000

## Getting Started in 5 Minutes

### 1. Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install iverilog gtkwave verilator make
```

**macOS:**
```bash
brew install icarus-verilog gtkwave verilator
```

### 2. Run Your First Simulation

```bash
cd Miyamii-4000
make sim
```

This will:
- Compile all Verilog files
- Run the testbench
- Generate waveform file (`miyamii_4000_tb.vcd`)

### 3. View Waveforms

```bash
make view
```

Opens GTKWave to see:
- Clock signals (clk, phi1, phi2)
- Program counter (pc_current)
- CPU state (cpu_state)
- Accumulator value
- Carry flag
- Instructions being executed

### 4. Write Your First Program

Create a file `my_program.asm`:

```assembly
; Hello World equivalent - blink pattern on ROM port
START:
    LDM 5           ; Load pattern 0101
    WRR             ; Write to ROM port
    LDM 10          ; Load pattern 1010
    WRR             ; Write to ROM port
    JUN START       ; Loop forever
```

### 5. Check Your Design

```bash
make lint
```

This runs Verilator's lint checker to catch common issues.

---

## What to Explore Next

### Understanding the Architecture

1. **Read the docs:**
   - `docs/README.md` - Full architecture guide
   - `docs/INSTRUCTION_SET.md` - All 45+ instructions

2. **Look at examples:**
   - `examples/fibonacci.asm` - Fibonacci sequence calculator
   - `examples/bcd_counter.asm` - BCD counter with decimal adjust

3. **Explore the code:**
   - `src/miyamii_4000.v` - Top-level processor
   - `src/alu.v` - See how arithmetic works
   - `src/control_fsm.v` - 8-state instruction cycle

### Modify the Testbench

Open `src/miyamii_4000_tb.v` and modify the test program:

```verilog
// Around line 94, change the program:
rom_mem[0] = 8'hD5;    // LDM 5
rom_mem[1] = 8'hF2;    // IAC (5+1=6)
rom_mem[2] = 8'hF2;    // IAC (6+1=7)
```

Then run: `make sim && make view`

### Try Different Instructions

Common operations:

```assembly
; Arithmetic
LDM 5       ; Load 5
IAC         ; Increment (now 6)
XCH 0       ; Save to R0
ADD 0       ; Add R0 to accumulator (now 12)

; Logic
CMA         ; Complement accumulator
RAL         ; Rotate left through carry
RAR         ; Rotate right through carry

; Branching
JCN Z, ZERO ; Jump if accumulator is zero
JUN ADDR    ; Jump unconditional
JMS SUBR    ; Call subroutine
BBL 0       ; Return from subroutine
```

---

## Troubleshooting

### Simulation doesn't run
```bash
# Check if iverilog is installed
which iverilog

# Try compiling manually
iverilog -o sim src/*.v
vvp sim
```

### No waveforms
```bash
# Check if VCD file was generated
ls -l miyamii_4000_tb.vcd

# Open manually
gtkwave miyamii_4000_tb.vcd
```

### Lint errors
```bash
# Run lint to see details
make lint

# Common issues:
# - Unused variables: Safe to ignore if intentional
# - Width mismatches: Check bit widths in assignments
```

---

## Next Steps

### For Learning
1. Run the basic simulation
2. View waveforms and understand timing
3. Read instruction set documentation
4. Modify testbench with your own program
5. Trace through an instruction cycle step by step

### For Development
1. Add new test cases to testbench
2. Write assembly programs
3. Create a simple assembler (see `tools/assembler.py`)
4. Add more peripherals (UART, timer, etc.)
5. Optimize the design

### For ASIC Flow
1. Install OpenLane and SKY130 PDK
2. Review `config.tcl` (main configuration)
3. Run: `./run_openlane.sh` (Docker helper)
   - Or: `docker run -it --rm -v $(pwd):/project efabless/openlane:latest bash -c "cd /project && flow.tcl -design . -tag run1"`
4. Analyze area/timing results
5. Iterate on design constraints

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `src/miyamii_4000.v` | Top-level processor module |
| `src/miyamii_4000_tb.v` | Testbench with example program |
| `openlane/config.json` | OpenLane ASIC flow configuration |
| `docs/INSTRUCTION_SET.md` | Complete instruction reference |
| `Makefile` | Build automation |

---

## Tips

1. **Start simple**: Begin with basic instructions (LDM, ADD, LD)
2. **Use the testbench**: Modify it rather than starting from scratch
3. **Check waveforms**: They're your best debugging tool
4. **Read the ISA**: The instruction set doc has examples
5. **One instruction at a time**: Debug by examining each instruction's effect

---

## Getting Help

1. Check `docs/README.md` for detailed architecture info
2. Read `docs/INSTRUCTION_SET.md` for instruction syntax
3. Look at example programs in `examples/`
4. Run `make help` to see available commands

---

## Success Checklist

After following this guide, you should be able to:

- Compile the processor design
- Run simulations
- View waveforms in GTKWave
- Understand the basic instruction set
- Write simple assembly programs
- Modify the testbench
- Know where to find detailed documentation

**Ready to build something awesome? Let's go!**
