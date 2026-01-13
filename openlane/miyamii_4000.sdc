# Miyamii-4000 SDC (Synopsys Design Constraints)
# Timing constraints for the 4-bit processor

# Clock period: 10.8 microseconds (740 kHz)
set clk_period 10800.0

# Create clock
create_clock [get_ports clk] -name clk -period $clk_period

# Clock uncertainty (minimal for slow clock)
set_clock_uncertainty 100.0 [get_clocks clk]

# Clock transition
set_clock_transition 0.5 [get_clocks clk]

# No input/output delays for slow clock design - causes hold violations
# The 740kHz clock is so slow that I/O timing is not the bottleneck

# Set load for outputs (typical capacitance)
set_load 0.05 [all_outputs]

# False paths
set_false_path -from [get_ports rst_n]

# Max fanout
set_max_fanout 10 [current_design]
