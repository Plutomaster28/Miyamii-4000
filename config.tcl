# OpenLane Configuration for Miyamii-4000 Processor
# 4-bit microprocessor design

set ::env(DESIGN_NAME) "miyamii_4000"

# Design files - exclude testbench
set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/src/miyamii_4000.v \
    $::env(DESIGN_DIR)/src/alu.v \
    $::env(DESIGN_DIR)/src/register_file.v \
    $::env(DESIGN_DIR)/src/pc_stack.v \
    $::env(DESIGN_DIR)/src/instruction_decoder.v \
    $::env(DESIGN_DIR)/src/control_fsm.v \
"
set ::env(VERILOG_FILES_BLACKBOX) ""

# Clock configuration
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10800"
set ::env(CLOCK_NET) "clk"

# Floorplan configuration - Unique rectangular shape with branding margins
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 1400 900"
set ::env(FP_CORE_UTIL) "25"
set ::env(FP_ASPECT_RATIO) "1.5"

# Add margins for branding text (100um on all sides)
set ::env(FP_IO_VEXTEND) "2"
set ::env(FP_IO_HEXTEND) "2"
set ::env(BOTTOM_MARGIN_MULT) "12"
set ::env(TOP_MARGIN_MULT) "12"
set ::env(LEFT_MARGIN_MULT) "8" 
set ::env(RIGHT_MARGIN_MULT) "8"

# Create visual separation between functional blocks
set ::env(FP_PDN_VPITCH) "50"
set ::env(FP_PDN_HPITCH) "50"
set ::env(FP_PDN_VWIDTH) "3.1"
set ::env(FP_PDN_HWIDTH) "3.1"

# Add some visual flair with routing layers
set ::env(RT_MAX_LAYER) "met4"

# Placement configuration - create visual patterns
set ::env(PL_TARGET_DENSITY) "0.30"
set ::env(PL_TIME_DRIVEN) "1"
set ::env(PL_ROUTABILITY_DRIVEN) "1"

# Create visual clustering of related logic
set ::env(PL_RANDOM_GLB_PLACEMENT) "0"
set ::env(PL_RANDOM_INITIAL_PLACEMENT) "0"

# Synthesis configuration
set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(SYNTH_BUFFERING) "1"
set ::env(SYNTH_SIZING) "1"
set ::env(SYNTH_MAX_FANOUT) "10"

# Routing configuration
set ::env(ROUTING_CORES) "4"
set ::env(GRT_OVERFLOW_ITERS) "100"
set ::env(GRT_ANT_ITERS) "15"
set ::env(GRT_ADJUSTMENT) "0.3"

# Diode insertion
set ::env(DIODE_INSERTION_STRATEGY) "3"

# CTS configuration
set ::env(CTS_TARGET_SKEW) "200"
set ::env(CTS_TOLERANCE) "100"

# Skip timing optimization during CTS to avoid buffer explosion
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) "0"
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "0"

# Increase buffer limit if resizer still runs
set ::env(PL_RESIZER_MAX_SLEW_MARGIN) "0"
set ::env(PL_RESIZER_MAX_CAP_MARGIN) "0"

# LVS/DRC
set ::env(RUN_CVC) "1"
set ::env(MAGIC_DRC_USE_GDS) "1"

# Fill insertion
set ::env(FILL_INSERTION) "1"

# Timing
set ::env(SYNTH_TIMING_DERATE) "0.05"
set ::env(QUIT_ON_TIMING_VIOLATIONS) "0"
set ::env(QUIT_ON_MAGIC_DRC) "0"
set ::env(QUIT_ON_LVS_ERROR) "0"

# Pin configuration
set ::env(FP_PIN_ORDER_CFG) "$::env(DESIGN_DIR)/openlane/pin_order.cfg"

# SDC file
set ::env(BASE_SDC_FILE) "$::env(DESIGN_DIR)/openlane/miyamii_4000.sdc"

# Let OpenLane auto-detect the standard cell library
# (will use sky130_fd_sc_hd by default for sky130A PDK)

# Don't use powered verilog
set ::env(USE_POWER_PINS) "0"

# Antenna repair
set ::env(GRT_REPAIR_ANTENNAS) "1"

# Flow control
set ::env(RUN_KLAYOUT) "0"
set ::env(RUN_KLAYOUT_XOR) "0"

# Output
set ::env(GENERATE_FINAL_SUMMARY_REPORT) "1"
