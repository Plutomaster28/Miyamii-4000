#!/bin/bash
# Add custom branding to the final GDS

# Determine the correct base directory
if [ -d "/openlane/designs/Miyamii-4000" ]; then
    # Running inside Docker container
    BASE_DIR="/openlane/designs/Miyamii-4000"
else
    # Running on host - get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    BASE_DIR="$SCRIPT_DIR"
fi

echo "Working in: $BASE_DIR"
cd "$BASE_DIR" || exit 1

# Find the most recent run directory
RUN_DIR=$(ls -td runs/RUN_* 2>/dev/null | head -1)

if [ -z "$RUN_DIR" ]; then
    echo "No run directory found in $BASE_DIR/runs"
    echo "Available directories:"
    ls -la runs/ 2>/dev/null || echo "runs/ directory doesn't exist"
    exit 1
fi

echo "Found run: $RUN_DIR"

GDS_FILE="$RUN_DIR/results/final/gds/miyamii_4000.gds"

if [ ! -f "$GDS_FILE" ]; then
    echo "GDS file not found at $GDS_FILE"
    echo "Checking what exists in results/final:"
    ls -la "$RUN_DIR/results/final/" 2>/dev/null
    exit 1
fi

echo "Adding branding to $GDS_FILE"

# Copy original
cp "$GDS_FILE" "$GDS_FILE.backup"

OUTPUT_GDS="${GDS_FILE/.gds/_branded.gds}"

# Find PDK path
if [ -d "$PDK_ROOT/sky130A" ]; then
    TECH_FILE="$PDK_ROOT/sky130A/libs.tech/magic/sky130A.tech"
elif [ -d "/home/miyamii/.ciel/sky130A" ]; then
    TECH_FILE="/home/miyamii/.ciel/sky130A/libs.tech/magic/sky130A.tech"
else
    echo "Warning: Cannot find sky130A tech file, metal layers may not work correctly"
    TECH_FILE=""
fi

if [ -n "$TECH_FILE" ] && [ -f "$TECH_FILE" ]; then
    echo "Using tech file: $TECH_FILE"
    TECH_ARG="-T $TECH_FILE"
else
    echo "Tech file not found, using default"
    TECH_ARG=""
fi

# Use magic to add text with proper technology
magic -dnull -noconsole $TECH_ARG << EOF
gds read $GDS_FILE
load miyamii_4000

# Die size: 1400um x 900um
# Bottom right corner branding (absolute positioning from die edge)
# M4K signature: smaller text, 5um from right edge, 5um from bottom

# M - letter (6um wide, 35um tall)
box 1340um 10um 1346um 45um
paint met5
box 1346um 38um 1354um 45um
paint met5
box 1354um 10um 1360um 45um
paint met5

# 4 - number
box 1365um 10um 1371um 45um
paint met5
box 1365um 28um 1380um 34um
paint met5
box 1374um 22um 1380um 45um
paint met5

# K - letter
box 1385um 10um 1391um 45um
paint met5
box 1391um 26um 1395um 32um
paint met5
box 1391um 24um 1395um 30um
paint met5

# Top left corner: "Miyamii-4000" 
# 5um from left edge, 5um from top (y=900-5=895)
# Smaller text: 6um wide, 35um tall

# M
box 5um 860um 11um 895um
paint met5
box 11um 888um 19um 895um
paint met5
box 19um 860um 25um 895um
paint met5

# I
box 30um 860um 36um 895um
paint met5

# Y
box 41um 860um 47um 877um
paint met5
box 47um 875um 53um 895um
paint met5
box 53um 860um 59um 877um
paint met5

# A
box 64um 860um 70um 895um
paint met5
box 70um 888um 78um 895um
paint met5
box 78um 860um 84um 895um
paint met5

# M
box 89um 860um 95um 895um
paint met5
box 95um 888um 103um 895um
paint met5
box 103um 860um 109um 895um
paint met5

# I
box 114um 860um 120um 895um
paint met5

# I
box 125um 860um 131um 895um
paint met5

# Dash
box 136um 876um 144um 880um
paint met5

# 4
box 149um 860um 155um 895um
paint met5
box 149um 876um 164um 882um
paint met5
box 158um 870um 164um 895um
paint met5

# 0
box 169um 860um 182um 895um
paint met5
box 169um 860um 182um 866um
paint met5
box 169um 889um 182um 895um
paint met5

# 0
box 187um 860um 200um 895um
paint met5
box 187um 860um 200um 866um
paint met5
box 187um 889um 200um 895um
paint met5

# 0
box 205um 860um 218um 895um
paint met5
box 205um 860um 218um 866um
paint met5
box 205um 889um 218um 895um
paint met5

save
gds write $OUTPUT_GDS
quit
EOF

if [ -f "$OUTPUT_GDS" ]; then
    echo "✓ Branded GDS created: $OUTPUT_GDS"
    echo "View it with: klayout $OUTPUT_GDS"
else
    echo "✗ Failed to create branded GDS"
    exit 1
fi
