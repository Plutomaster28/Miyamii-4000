# OpenLane Flow Guide for Miyamii-4000

## Prerequisites

1. **OpenLane Installation**
   ```bash
   # Clone OpenLane
   git clone https://github.com/The-OpenROAD-Project/OpenLane.git
   cd OpenLane
   
   # Install dependencies and build
   make
   ```

2. **PDK Installation**
   OpenLane typically installs SKY130 PDK automatically during setup.

## Quick Start

### Method 1: Docker (Recommended - No Installation Required)

```bash
# From your project directory
cd /home/miyamii/Miyamii-4000

# Pull OpenLane Docker image
docker pull efabless/openlane:latest

# Run OpenLane flow directly on your design
docker run -it --rm \
  -v $(pwd):/project \
  -v /tmp/openlane_run:/openlane_run \
  efabless/openlane:latest \
  bash -c "cd /project && flow.tcl -design . -tag run1"
```

### Method 2: Docker Interactive Mode

```bash
# Start interactive OpenLane container
cd /home/miyamii/Miyamii-4000

docker run -it --rm \
  -v $(pwd):/project \
  -v /tmp/openlane_run:/openlane_run \
  efabless/openlane:latest

# Inside container:
cd /project
flow.tcl -interactive

# In the OpenLane shell:
prep -design . -tag run1
run_synthesis
run_floorplan
run_placement
run_cts
run_routing
run_magic
run_magic_spice_export
run_lvs
run_magic_drc
```

### Method 3: Local OpenLane Installation

If you have OpenLane installed locally:

```bash
# Navigate to your design directory
cd /home/miyamii/Miyamii-4000

# Run directly (OpenLane will find config.tcl)
flow.tcl -design . -tag run1

# Or interactive:
flow.tcl -interactive
# Then: prep -design . -tag run1
```

### Method 4: Copy to OpenLane Designs Directory

If you prefer the traditional approach:

```bash
# Copy design to OpenLane
cp -r /home/miyamii/Miyamii-4000 <openlane_root>/designs/

# Run from OpenLane root
cd <openlane_root>
./flow.tcl -design miyamii_4000 -tag run1
```

## Flow Steps Explained

### 1. Synthesis
Converts RTL (Verilog) to gate-level netlist.

```tcl
run_synthesis
```

**What to check:**
- Cell count and types
- Critical path delay
- Area utilization
- No synthesis errors

**Expected Results:**
- ~100-200 cells (depending on optimization)
- Area: TBD
- Delay: Should meet 10.8μs timing

### 2. Floorplanning
Defines the chip area and places macros.

```tcl
run_floorplan
```

**What to check:**
- Die area matches config (500x500 μm²)
- Core utilization (~50%)
- Power grid setup

### 3. Placement
Places standard cells in the core area.

```tcl
run_placement
```

**What to check:**
- Placement density
- No overflow
- Routability metrics

### 4. Clock Tree Synthesis (CTS)
Builds clock distribution network.

```tcl
run_cts
```

**What to check:**
- Clock skew
- Clock latency
- Buffer insertion

### 5. Routing
Connects all cells with metal layers.

```tcl
run_routing
```

**What to check:**
- No DRC violations
- No antenna violations
- Routing overflow = 0

### 6. Physical Verification
Runs DRC, LVS, and antenna checks.

```tcl
run_magic
run_magic_drc
run_lvs
```

**What to check:**
- DRC violations = 0
- LVS clean
- No antenna issues

## Configuration File Breakdown

### config.tcl (Main Configuration)

```tcl
# Design name
set ::env(DESIGN_NAME) "miyamii_4000"

# Source files - automatically includes all .v files in src/
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Clock Settings
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10800"    # 10.8 μs = 740 kHz (in ps)

# Die Settings
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 500 500"  # 500x500 μm
set ::env(FP_CORE_UTIL) "50"       # 50% utilization

# Placement Settings
set ::env(PL_TARGET_DENSITY) "0.55"
set ::env(PL_TIME_DRIVEN) "1"
set ::env(PL_ROUTABILITY_DRIVEN) "1"

# Routing Settings
set ::env(GRT_OVERFLOW_ITERS) "100"
set ::env(GRT_ANT_ITERS) "15"

# Diode Insertion
set ::env(DIODE_INSERTION_STRATEGY) "3"

# Pin and timing files
set ::env(FP_PIN_ORDER_CFG) "$::env(DESIGN_DIR)/openlane/pin_order.cfg"
set ::env(BASE_SDC_FILE) "$::env(DESIGN_DIR)/openlane/miyamii_4000.sdc"
```

### Key Parameters Explained

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `CLOCK_PERIOD` | 10800 | Clock period in picoseconds (10.8 μs) |
| `DIE_AREA` | 0 0 500 500 | Die size: 500μm × 500μm |
| `FP_CORE_UTIL` | 50 | Use 50% of core area for cells |
| `PL_TARGET_DENSITY` | 0.55 | Place cells at 55% density |
| `DIODE_INSERTION_STRATEGY` | 3 | Aggressive antenna prevention |

## Customization Options

### Increase Die Area (if needed)

```tcl
set ::env(DIE_AREA) "0 0 750 750"    # Larger area
set ::env(FP_CORE_UTIL) "40"         # Lower utilization
```

### Tighten Timing

```tcl
set ::env(CLOCK_PERIOD) "8000"       # 8 μs = higher frequency
set ::env(PL_TIME_DRIVEN) "1"
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) "1"
```

### Optimize for Area

```tcl
set ::env(SYNTH_STRATEGY) "AREA 3"
set ::env(FP_CORE_UTIL) "70"         # Higher utilization
set ::env(PL_TARGET_DENSITY) "0.75"
```

### Optimize for Power

```tcl
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(CLOCK_GATING_CHECK) "1"
```

## Analyzing Results

### Check Reports

Results are in: `runs/<tag>/reports/`

Key reports:
- `synthesis/1-synthesis.AREA.rpt` - Area breakdown
- `synthesis/1-synthesis.stat` - Cell statistics
- `cts/2-cts.timing` - Clock tree timing
- `routing/3-routing.drc` - DRC violations
- `finishing/3-finishing.lvs` - LVS results

### View Layout

```bash
# Open in Magic
magic -d XR runs/<tag>/results/magic/miyamii_4000.mag

# Or view GDS
klayout runs/<tag>/results/final/gds/miyamii_4000.gds
```

## Common Issues & Solutions

### Issue 1: Synthesis Fails
**Symptoms:** Errors during `run_synthesis`

**Solutions:**
- Check Verilog syntax with: `make lint`
- Verify all modules are in VERILOG_FILES list
- Check for unsupported constructs

### Issue 2: Placement Overflow
**Symptoms:** Placement overflow > 0

**Solutions:**
- Increase die area
- Reduce core utilization
- Simplify design

### Issue 3: Routing Fails
**Symptoms:** Cannot complete routing

**Solutions:**
```tcl
set ::env(GRT_OVERFLOW_ITERS) "200"  # More iterations
set ::env(GRT_ANT_MARGIN) "20"       # More margin
set ::env(FP_PDN_VPITCH) "50"        # Larger pitch
set ::env(FP_PDN_HPITCH) "50"
```

### Issue 4: Timing Violations
**Symptoms:** Setup/hold violations

**Solutions:**
- Increase CLOCK_PERIOD
- Enable timing optimization
- Add buffers manually
- Reduce wire load

### Issue 5: DRC Violations
**Symptoms:** DRC errors in final check

**Solutions:**
- Increase die area
- Reduce density
- Check metal stack usage
- Run detailed routing

## Performance Targets

### Expected Metrics

| Metric | Target | Acceptable Range |
|--------|--------|------------------|
| Area | ~0.1 mm² | 0.08 - 0.15 mm² |
| Cell Count | 150-250 | 100-300 |
| Frequency | 740 kHz | 500 kHz - 1 MHz |
| Power | <1 mW | 0.5 - 2 mW |
| Utilization | 50% | 40% - 60% |

### Critical Paths

Watch for timing on:
- ALU carry chain
- Register file reads
- Instruction decode logic
- PC increment path

## Tips for Success

1. **Start Simple**
   - Run default flow first
   - Understand the baseline
   - Then optimize

2. **Check Each Step**
   - Don't skip verification
   - Review reports after each stage
   - Fix issues early

3. **Iterate**
   - First run rarely perfect
   - Adjust parameters based on results
   - Document what works

4. **Use Interactive Mode**
   - Better for learning
   - Can inspect intermediate results
   - Easier to debug

5. **Read the Logs**
   - Logs in `runs/<tag>/logs/`
   - Contains detailed information
   - Error messages are helpful

## Example Run Session

```bash
# Using Docker (easiest method)
cd ~/Miyamii-4000

# Option 1: Run complete flow
docker run -it --rm \
  -v $(pwd):/project \
  efabless/openlane:latest \
  bash -c "cd /project && flow.tcl -design . -tag test1"

# Option 2: Interactive mode
docker run -it --rm \
  -v $(pwd):/project \
  efabless/openlane:latest

# Inside container:
cd /project
flow.tcl -interactive

# OpenLane commands:
prep -design . -tag test1 -overwrite
run_synthesis
# Check: runs/test1/reports/synthesis/

run_floorplan
run_placement
run_cts
run_routing
run_magic
run_magic_drc
run_lvs

# Exit and view results
exit

# View layout (from host machine, if Magic installed)
magic -d XR runs/test1/results/magic/miyamii_4000.mag
```

## Next Steps After Successful Flow

1. **Document Results**
   - Save reports
   - Screenshot layout
   - Record metrics

2. **Optimize**
   - Try different strategies
   - Compare results
   - Find best configuration

3. **Verification**
   - Post-layout simulation
   - Timing verification
   - Power analysis

4. **Tape Out**
   - Submit to Tiny Tapeout
   - Or use eFabless shuttle
   - Get real silicon!

## Resources

- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [SKY130 PDK Docs](https://skywater-pdk.readthedocs.io/)
- [OpenROAD Flow](https://openroad.readthedocs.io/)
- [Magic VLSI](http://opencircuitdesign.com/magic/)

## Support

If you get stuck:
1. Check OpenLane documentation
2. Review example designs
3. Ask on OpenLane Slack
4. Check GitHub issues

---

**Good luck with your tape out!**
