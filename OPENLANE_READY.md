# Ready to Run with OpenLane!

## What's Been Set Up

Your Miyamii-4000 design is **completely ready** to run through the OpenLane ASIC flow using Docker. No need to move files around!

## Files Created

**config.tcl** - Main OpenLane configuration (root directory)  
**openlane/config.json** - Alternative JSON config (backup)  
**openlane/pin_order.cfg** - Pin placement configuration  
**openlane/miyamii_4000.sdc** - Timing constraints  
**run_openlane.sh** - Docker helper script (makes it super easy!)  

## Quick Start - 3 Ways to Run

### Method 1: Use the Helper Script (Easiest!)

```bash
cd ~/Miyamii-4000
./run_openlane.sh
```

Choose from the menu:
1. **Complete flow** - Runs everything automatically
2. **Interactive** - Step by step control
3. **Shell** - Explore the container

### Method 2: One Command Docker Run

```bash
cd ~/Miyamii-4000

# Run the complete flow
docker run -it --rm \
  -v $(pwd):/project \
  efabless/openlane:latest \
  bash -c "cd /project && flow.tcl -design . -tag run1"
```

Results will be in: `runs/run1/`

### Method 3: Interactive Docker Session

```bash
cd ~/Miyamii-4000

docker run -it --rm \
  -v $(pwd):/project \
  efabless/openlane:latest

# Inside container:
cd /project
flow.tcl -interactive

# Then run commands:
prep -design . -tag myrun
run_synthesis
run_floorplan
run_placement
run_cts
run_routing
run_magic
run_lvs
run_magic_drc
```

## What Happens During the Run

### 1. Synthesis (2-5 minutes)
- Converts Verilog to gates
- Optimizes logic
- **Check:** `runs/<tag>/reports/synthesis/`

### 2. Floorplan (1-2 minutes)
- Creates chip layout
- Places power grid
- **Check:** `runs/<tag>/results/floorplan/`

### 3. Placement (2-3 minutes)
- Places standard cells
- Optimizes positions
- **Check:** `runs/<tag>/results/placement/`

### 4. Clock Tree (1-2 minutes)
- Builds clock distribution
- Minimizes skew
- **Check:** `runs/<tag>/reports/cts/`

### 5. Routing (5-10 minutes)
- Connects all cells
- Fixes violations
- **Check:** `runs/<tag>/reports/routing/`

### 6. Verification (2-3 minutes)
- DRC checks
- LVS verification
- Antenna checks
- **Check:** `runs/<tag>/reports/finishing/`

**Total Time:** 15-30 minutes for complete flow

## Key Configuration Parameters

From `config.tcl`:

```tcl
DESIGN_NAME:       "miyamii_4000"
CLOCK_PERIOD:      10800 ps (10.8 μs = 740 kHz)
DIE_AREA:          500 μm × 500 μm
CORE_UTILIZATION:  50%
TARGET_DENSITY:    55%
```

## Expected Results

| Metric | Estimated Value |
|--------|-----------------|
| **Total Cells** | 150-250 cells |
| **Area** | ~0.1 mm² |
| **Max Frequency** | 740 kHz - 1 MHz |
| **Power** | < 1 mW |
| **DRC Violations** | 0 (target) |
| **LVS Status** | Clean (target) |

## Where to Find Results

After the run completes:

```
runs/<tag>/
├── reports/              # All reports
│   ├── synthesis/        # Cell counts, area
│   ├── placement/        # Density, congestion
│   ├── cts/              # Clock tree stats
│   ├── routing/          # Routing metrics
│   └── finishing/        # DRC/LVS results
├── results/
│   ├── magic/            # Layout files (.mag)
│   ├── final/
│   │   ├── gds/          # Final GDS file
│   │   ├── def/          # DEF netlist
│   │   └── verilog/      # Gate-level netlist
└── logs/                 # Detailed logs
```

## Viewing the Layout

### If Magic is installed on your system:

```bash
cd ~/Miyamii-4000/runs/<tag>/results/magic
magic -d XR miyamii_4000.mag
```

### View GDS (if KLayout installed):

```bash
klayout runs/<tag>/results/final/gds/miyamii_4000.gds
```

### Or extract from Docker:

```bash
# The files are already on your host system!
# Just navigate to runs/<tag>/results/final/gds/
```

## Troubleshooting

### "Docker not found"
```bash
# Install Docker
sudo apt update && sudo apt install docker.io
sudo usermod -aG docker $USER
# Log out and back in
```

### "Permission denied"
```bash
sudo chmod 666 /var/run/docker.sock
# Or run with sudo (not recommended for production)
```

### "Image pull failed"
```bash
# Check internet connection
# Try: docker pull efabless/openlane:latest
```

### "Synthesis fails"
```bash
# Check Verilog files
make lint

# View synthesis log
cat runs/<tag>/logs/synthesis/1-synthesis.log
```

### "Routing overflow"
```bash
# Edit config.tcl:
set ::env(DIE_AREA) "0 0 750 750"  # Increase size
set ::env(FP_CORE_UTIL) "40"       # Reduce utilization
```

## Customizing the Run

### Want a different die size?
Edit `config.tcl`:
```tcl
set ::env(DIE_AREA) "0 0 1000 1000"  # 1mm × 1mm
```

### Want faster clock?
```tcl
set ::env(CLOCK_PERIOD) "5000"  # 5 μs = 200 kHz
```

### Want higher density?
```tcl
set ::env(FP_CORE_UTIL) "70"
set ::env(PL_TARGET_DENSITY) "0.75"
```

## Next Steps After Successful Run

1. **Review Reports**
   - Check cell count
   - Verify timing is met
   - Look for violations

2. **View Layout**
   - Open in Magic or KLayout
   - Inspect routing
   - Check for issues

3. **Iterate**
   - Adjust parameters
   - Re-run flow
   - Compare results

4. **Submit to Shuttle**
   - Tiny Tapeout
   - eFabless shuttle
   - Get real chips!

## Quick Reference

```bash
# Pull latest image
docker pull efabless/openlane:latest

# Run complete flow
./run_openlane.sh

# Or manually:
docker run -it --rm -v $(pwd):/project efabless/openlane:latest \
  bash -c "cd /project && flow.tcl -design . -tag run1"

# View results
ls -lh runs/run1/results/final/gds/

# Check reports
cat runs/run1/reports/synthesis/1-synthesis.AREA.rpt
cat runs/run1/reports/finishing/3-finishing.drc
```

## Help & Resources

- **This project's guide:** `docs/OPENLANE_GUIDE.md`
- **OpenLane docs:** https://openlane.readthedocs.io/
- **SKY130 PDK:** https://skywater-pdk.readthedocs.io/
- **Tiny Tapeout:** https://tinytapeout.com/

## You're All Set!

Your design is configured and ready to go. Just run:

```bash
./run_openlane.sh
```

And watch your 4-bit processor get synthesized into real chip layout!

**Good luck with your first ASIC run!**

---

*Last updated: January 12, 2026*
