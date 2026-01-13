#!/bin/bash
# Check if OpenLane Docker container can find the PDK

echo "Checking OpenLane PDK setup..."
echo ""

docker run --rm efabless/openlane:latest \
  bash -c '
    echo "=== PDK Root: ==="
    echo $PDK_ROOT
    ls -la $PDK_ROOT 2>/dev/null || echo "PDK_ROOT not found!"
    
    echo ""
    echo "=== PDK: ==="
    echo $PDK
    
    echo ""
    echo "=== Checking for sky130A: ==="
    ls -la $PDK_ROOT/sky130A 2>/dev/null || echo "sky130A not found!"
    
    echo ""
    echo "=== Checking for standard cells: ==="
    find $PDK_ROOT -name "sky130_fd_sc_hd" -type d 2>/dev/null || echo "sky130_fd_sc_hd not found!"
    
    echo ""
    echo "=== OpenLane version: ==="
    flow.tcl -version 2>/dev/null || echo "flow.tcl not in PATH"
    
    echo ""
    echo "If PDK is found above, your setup is good!"
  '
