# Miyamii-4000 4-Bit Processor

🚀 An overkill high school engineering project - A complete 4-bit microprocessor implementation in Verilog, inspired by the Intel 4004 architecture, designed for the OpenLane ASIC flow.

## Quick Stats

- **Architecture**: 4-bit data path, 12-bit address space
- **Clock**: 740 kHz (10.8 μs period)
- **Instructions**: 45+ instructions, 8-cycle execution
- **Memory**: 4KB ROM, 1280x4-bit RAM
- **Registers**: 16x4-bit + 4-bit accumulator + carry flag
- **Stack**: 3-level deep for subroutine calls

## Features

✅ Complete instruction set (arithmetic, logic, branching, I/O)  
✅ Register file with pair addressing  
✅ 3-level call stack  
✅ Conditional branches  
✅ BCD arithmetic support  
✅ RAM and ROM I/O ports  
✅ OpenLane-ready configuration  
✅ Full testbench included  

## Quick Start

### Simulation

```bash
# Compile and run
make sim

# View waveforms
make view

# Lint check
make lint
```

### OpenLane Flow

**Using Docker (Easiest - No Installation):**
```bash
# Use the helper script
./run_openlane.sh

# Or run directly
docker run -it --rm -v $(pwd):/project \
  efabless/openlane:latest \
  bash -c "cd /project && flow.tcl -design . -tag run1"
```

**With Local OpenLane:**
```bash
cd <openlane_root>
./flow.tcl -design <path_to_Miyamii-4000> -tag run1
```

## Project Structure

```
Miyamii-4000/
├── src/                    # Verilog source files
│   ├── miyamii_4000.v     # Top-level processor
│   ├── alu.v              # ALU with 16 operations
│   ├── register_file.v    # 16x4-bit registers
│   ├── pc_stack.v         # PC with 3-level stack
│   ├── instruction_decoder.v  # Instruction decoder
│   ├── control_fsm.v      # 8-state control FSM
│   └── miyamii_4000_tb.v  # Testbench
├── openlane/              # OpenLane configuration
│   ├── config.json        # Alternative config format
│   ├── pin_order.cfg      # Pin placement
│   └── miyamii_4000.sdc   # Timing constraints
├── docs/                  # Documentation
│   ├── README.md          # Detailed documentation
│   ├── INSTRUCTION_SET.md # Complete ISA reference
│   ├── ARCHITECTURE_DIAGRAM.md # Visual diagrams
│   └── OPENLANE_GUIDE.md  # ASIC flow guide
├── examples/              # Example programs
│   ├── fibonacci.asm      # Fibonacci sequence
│   └── bcd_counter.asm    # BCD counter
├── tools/                 # Development tools
│   └── assembler.py       # Python assembler
├── config.tcl             # Main OpenLane config
├── run_openlane.sh        # Docker helper script
└── Makefile              # Build automation
```

## Architecture Highlights

### Instruction Set Architecture
- **1-byte instructions**: Arithmetic, logic, load/store
- **2-byte instructions**: Jumps, immediate loads, conditional branches
- **I/O instructions**: RAM/ROM port operations

### Example Program
```assembly
START:  LDM 5       ; Load 5 into accumulator
        XCH 0       ; Exchange with register 0
        LDM 3       ; Load 3
        ADD 0       ; Add R0 (result: 8)
        JUN START   ; Jump back
```

### Register Architecture
- 16 general-purpose registers (R0-R15)
- 8 register pairs for 8-bit operations
- 4-bit accumulator for ALU operations
- 1-bit carry flag

### Memory
- **ROM**: 4096 x 8-bit (program memory)
- **RAM**: 1280 x 4-bit (data memory)
- Separate address spaces

## Documentation

- **[Full Documentation](docs/README.md)** - Complete architecture and implementation details
- **[Instruction Set Reference](docs/INSTRUCTION_SET.md)** - All 45+ instructions with examples

## Tools Required

### For Simulation
- Icarus Verilog (iverilog)
- GTKWave (waveform viewer)
- Verilator (optional, for linting)

### For ASIC Flow
- OpenLane (ASIC flow)
- SKY130 PDK (or compatible)
- Magic (layout viewer)
- Klayout (GDS viewer)

## Building

```bash
# Run simulation
make sim

# View waveforms
make view

# Lint the design
make lint

# Clean build artifacts
make clean

# Show all targets
make help
```

## Performance

- **Frequency**: 740 kHz
- **Instruction time**: 86.4 μs (8 clock cycles)
- **Throughput**: ~11,574 instructions/second
- **Power**: TBD (post-synthesis)
- **Area**: TBD (post-synthesis)

## Module Hierarchy

```
miyamii_4000 (top module)
├── alu              (4-bit ALU)
├── register_file    (16x4 registers)
├── pc_stack         (PC + stack)
├── instruction_decoder (decode logic)
└── control_fsm      (8-state FSM)
```

## Testing

The included testbench verifies:
- ✅ Instruction fetch and decode
- ✅ Arithmetic operations (ADD, SUB, INC, DEC)
- ✅ Logic operations (CMA, RAL, RAR)
- ✅ Register operations (LD, XCH, FIM)
- ✅ Jump instructions (JUN, JCN, JMS)
- ✅ Subroutine calls and returns
- ✅ Stack operations

## Why This Project?

This started as a high school engineering project but evolved into a complete processor implementation because... why not go overkill? 😄

It's a great learning project for:
- Digital design and Verilog
- Computer architecture
- ASIC design flow with OpenLane
- Instruction set architecture
- Hardware-software interface

## Future Ideas

- [ ] Add comprehensive test suite
- [ ] Optimize for area/power
- [ ] Implement formal verification
- [ ] Create assembler/compiler
- [ ] Add peripherals (UART, SPI, timers)
- [ ] Multi-chip configuration
- [ ] Tape out with tiny tapeout!

## References

- Intel 4004 Microprocessor (1971)
- MCS-4 Family User's Manual
- OpenLane Documentation
- SKY130 PDK Documentation

## License

This is an educational/hobby project. Feel free to use, modify, and learn from it!

## Contributing

Found a bug? Have an idea? Feel free to open an issue or submit a PR!

---

**Made with ❤️ (and probably too much coffee) for a high school engineering project**

If you use this in your project, give it a ⭐!
