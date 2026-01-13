# Miyamii-4000 Processor

A 4-bit microprocessor implementation in Verilog, designed for the OpenLane ASIC flow. This processor is inspired by the Intel 4004 architecture and implements a complete instruction set with 4-bit data path and 12-bit address space.

## Architecture Overview

- **Data Path**: 4-bit parallel
- **Word Length**: 
  - Instructions: 8 bits
  - Data: 4 bits
- **Clock**: 2-phase, non-overlapping
- **Cycle Time**: 10.8 microseconds (740 kHz)
- **Instruction Cycle**: 8 clock cycles

## Key Features

### Register Architecture
- **Program Counter (PC)**: 12 bits with 3-level stack for subroutine calls
- **Index Registers**: 16 x 4-bit registers (can be addressed individually or as 8 pairs)
- **Accumulator**: 4-bit primary register for arithmetic/logic operations
- **Carry Flag**: 1-bit flag for arithmetic operations

### Memory Architecture
- **Program Memory (ROM)**: 4K x 8 bits (4096 bytes)
- **Data Memory (RAM)**: 1280 x 4 bits
- Separate address spaces for ROM and RAM

### Instruction Set
- **Machine Instructions**: Single-byte arithmetic, logic, and control operations
- **Two-Byte Instructions**: Jumps, immediate loads, and conditional branches
- **I/O Instructions**: RAM and ROM port operations
- Complete set of 45+ instructions including:
  - Arithmetic: ADD, SUB, INC, DEC, DAA
  - Logic: CMA, CMC, RAL, RAR
  - Control: JUN, JCN, JMS, BBL, ISZ
  - Data Transfer: LD, XCH, LDM, FIM
  - I/O: RDM, WRM, RDR, WRR, and status character access

## Module Hierarchy

```
miyamii_4000 (top)
├── alu.v              - 4-bit ALU with 16 operations
├── register_file.v    - 16x4-bit register array
├── pc_stack.v         - 12-bit PC with 3-level stack
├── instruction_decoder.v - Instruction decode and control signal generation
└── control_fsm.v      - 8-state instruction cycle FSM
```

## Directory Structure

```
Miyamii-4000/
├── src/
│   ├── miyamii_4000.v         - Top-level processor module
│   ├── alu.v                   - Arithmetic Logic Unit
│   ├── register_file.v         - Register file
│   ├── pc_stack.v              - Program counter and stack
│   ├── instruction_decoder.v   - Instruction decoder
│   ├── control_fsm.v           - Control FSM
│   └── miyamii_4000_tb.v       - Testbench
├── openlane/
│   ├── config.json             - OpenLane configuration
│   ├── pin_order.cfg           - Pin placement
│   └── miyamii_4000.sdc        - Timing constraints
└── docs/
    └── README.md               - This file
```

## Building with OpenLane

### Prerequisites
- OpenLane installed and configured
- PDK (e.g., SKY130) installed

### Running the Flow

```bash
# Navigate to OpenLane directory
cd <openlane_root>

# Run the full ASIC flow
./flow.tcl -design <path_to_Miyamii-4000> -tag miyamii_4000_run1

# Or run interactively
./flow.tcl -interactive
```

### Interactive OpenLane Commands

```tcl
package require openlane
prep -design <path_to_Miyamii-4000>

# Synthesis
run_synthesis

# Floorplanning
run_floorplan

# Placement
run_placement

# Clock Tree Synthesis
run_cts

# Routing
run_routing

# Final checks
run_magic
run_magic_spice_export
run_magic_drc
run_lvs
```

## Simulation

### Using Icarus Verilog

```bash
cd src/

# Compile
iverilog -o miyamii_4000_sim \
    miyamii_4000.v \
    alu.v \
    register_file.v \
    pc_stack.v \
    instruction_decoder.v \
    control_fsm.v \
    miyamii_4000_tb.v

# Run simulation
./miyamii_4000_sim

# View waveforms
gtkwave miyamii_4000_tb.vcd
```

### Using Verilator

```bash
verilator --cc --exe --build -j \
    miyamii_4000.v \
    alu.v \
    register_file.v \
    pc_stack.v \
    instruction_decoder.v \
    control_fsm.v \
    miyamii_4000_tb.cpp

./obj_dir/Vmiyamii_4000
```

## Instruction Cycle Timing

Each instruction executes in 8 clock cycles (states):

- **A1-A2**: Fetch first byte from ROM, load into instruction register
- **A3**: Decode instruction
- **M1-M2**: Execute or fetch second byte (for 2-byte instructions)
- **X1-X3**: Complete execution, write results, increment PC

## Design Specifications

### Timing
- **Clock Period**: 10.8 μs
- **Frequency**: 740 kHz
- **Instruction Time**: 86.4 μs (8 clock cycles)
- **MIPS**: ~0.011 (11,574 instructions/second)

### Area (estimated)
- **Registers**: ~70 flip-flops
- **Combinational Logic**: ~500-1000 gates (depending on optimization)
- **Total Area**: TBD after synthesis

## Pin Interface

### Inputs (38 pins)
- `clk` - Main clock
- `rst_n` - Active-low reset
- `phi1`, `phi2` - Two-phase clocks
- `rom_data[7:0]` - ROM data input
- `ram_data_in[3:0]` - RAM data input
- `rom_port_in[3:0]` - ROM port input
- `ram_port_in[3:0]` - RAM port input
- `test_pin` - Test signal for conditional jumps

### Outputs (46 pins)
- `rom_addr[11:0]` - ROM address
- `rom_ce` - ROM chip enable
- `ram_addr[11:0]` - RAM address
- `ram_data_out[3:0]` - RAM data output
- `ram_we`, `ram_ce` - RAM control signals
- `rom_port_out[3:0]`, `rom_port_we` - ROM port interface
- `ram_port_out[3:0]`, `ram_port_we` - RAM port interface
- `carry_flag` - Carry flag status
- `cpu_state[2:0]` - Current CPU state
- `stack_overflow`, `stack_underflow` - Stack status

## Example Programs

### Simple Addition
```assembly
LDM 5    ; Load 5 into accumulator
LD R0    ; Load register 0 into accumulator
ADD R1   ; Add register 1 to accumulator
```

### Subroutine Call
```assembly
        JMS SUBR    ; Call subroutine
        LDM 0       ; Continue here after return
        
SUBR:   LDM 8       ; Subroutine code
        IAC         ; Increment accumulator
        BBL 0       ; Return with 0 in accumulator
```

### Conditional Branch
```assembly
        LD R0       ; Load register 0
        JCN Z, ZERO ; Jump if accumulator is zero
        LDM 1       ; Not zero path
        JUN END     ; Jump to end
ZERO:   LDM 0       ; Zero path
END:    NOP         ; Continue
```

## Testing

The included testbench (`miyamii_4000_tb.v`) provides:
- Basic instruction execution tests
- Register operations
- Jump and branch testing
- Subroutine call/return
- Arithmetic operations

Run the testbench to verify functionality before synthesis.

## Known Limitations

- RAM banking (DCL instruction) is partially implemented
- Test pin functionality is minimal
- No interrupt support
- No DMA support

## Future Enhancements

- [ ] Complete RAM banking implementation
- [ ] Add comprehensive instruction test suite
- [ ] Implement formal verification
- [ ] Optimize for lower area/power
- [ ] Add pipeline optimization
- [ ] Implement cache system

## References

- Intel 4004 Datasheet
- MCS-4 Assembly Language Programming Manual
- OpenLane Documentation

## License

This is a educational/hobby project. Use at your own discretion.

## Author

Created for a high school engineering project - going overkill style! 🚀

---

**Note**: This processor is designed for educational purposes and as an OpenLane flow demonstration. It implements a complete 4-bit architecture suitable for ASIC fabrication.
