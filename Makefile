# Makefile for Miyamii-4000 Processor

# Verilog source files
SRC = src/miyamii_4000.v \
      src/alu.v \
      src/register_file.v \
      src/pc_stack.v \
      src/instruction_decoder.v \
      src/control_fsm.v

TB = src/miyamii_4000_tb.v

# Output files
SIM_OUT = miyamii_4000_sim
VCD_OUT = miyamii_4000_tb.vcd

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
VERILATOR = verilator
YOSYS = yosys

# Simulation targets
.PHONY: all sim view clean synth lint help

all: sim

# Compile and run simulation with Icarus Verilog
sim: $(SRC) $(TB)
	@echo "Compiling with Icarus Verilog..."
	$(IVERILOG) -o $(SIM_OUT) $(SRC) $(TB)
	@echo "Running simulation..."
	$(VVP) $(SIM_OUT)
	@echo "Simulation complete. VCD file: $(VCD_OUT)"

# View waveforms
view: $(VCD_OUT)
	@echo "Opening waveform viewer..."
	$(GTKWAVE) $(VCD_OUT) &

# Lint with Verilator
lint: $(SRC)
	@echo "Linting with Verilator..."
	$(VERILATOR) --lint-only -Wall $(SRC)

# Synthesize with Yosys (basic)
synth: $(SRC)
	@echo "Synthesizing with Yosys..."
	$(YOSYS) -p "read_verilog $(SRC); hierarchy -check -top miyamii_4000; proc; opt; fsm; opt; memory; opt; techmap; opt; abc -liberty <path_to_liberty>; opt; stat; write_verilog synth_miyamii_4000.v"

# OpenLane flow (requires OpenLane installation)
openlane:
	@echo "Running OpenLane flow..."
	@echo "Make sure OpenLane is installed and configured"
	cd $(OPENLANE_ROOT) && ./flow.tcl -design $(PWD) -tag miyamii_4000_run

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(SIM_OUT)
	rm -f $(VCD_OUT)
	rm -f *.vcd
	rm -f *.out
	rm -f synth_*.v
	rm -rf obj_dir/
	rm -f *.log

# Help
help:
	@echo "Miyamii-4000 Makefile targets:"
	@echo "  all       - Compile and run simulation (default)"
	@echo "  sim       - Compile and run simulation with Icarus Verilog"
	@echo "  view      - Open GTKWave to view waveforms"
	@echo "  lint      - Run Verilator lint checks"
	@echo "  synth     - Synthesize with Yosys (configure liberty path first)"
	@echo "  openlane  - Run OpenLane ASIC flow (requires OpenLane setup)"
	@echo "  clean     - Remove build artifacts"
	@echo "  help      - Show this help message"
