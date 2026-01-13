#!/bin/bash
# OpenLane Docker Helper Script for Miyamii-4000
# Makes running OpenLane with Docker easier

DESIGN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="efabless/openlane:latest"

# Check if user has PDK locally
if [ -d "$HOME/.volare/sky130A" ]; then
    echo "Found local PDK at $HOME/.volare"
    PDK_MOUNT="-v $HOME/.volare:/root/.volare"
    USE_LOCAL_PDK=true
else
    echo "No local PDK found. Will use Docker's internal setup."
    echo "Note: First run may take time to download PDK..."
    PDK_MOUNT=""
    USE_LOCAL_PDK=false
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Miyamii-4000 OpenLane Docker Runner${NC}"
echo "Design directory: $DESIGN_DIR"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Pull latest image if needed
echo -e "${YELLOW}Checking for latest OpenLane image...${NC}"
docker pull $IMAGE

echo ""
echo "Select mode:"
echo "1) Run complete flow (automated)"
echo "2) Interactive mode (step-by-step)"
echo "3) Shell only (explore)"
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo -e "${GREEN}Running complete ASIC flow...${NC}"
        docker run -it --rm \
            -v "$DESIGN_DIR:/project" \
            $PDK_MOUNT \
            $IMAGE \
            bash -c "
                volare enable --pdk sky130 2.0.1 || echo 'Using existing PDK'
                cd /project && flow.tcl -design . -tag docker_run_$(date +%Y%m%d_%H%M%S)
            "
        ;;
    2)
        echo -e "${GREEN}Starting interactive mode...${NC}"
        echo "Commands to run inside:"
        echo "  volare enable --pdk sky130 2.0.1  (if needed)"
        echo "  cd /project"
        echo "  flow.tcl -interactive"
        echo "  prep -design . -tag interactive_run"
        echo "  run_synthesis"
        echo "  run_floorplan"
        echo "  run_placement"
        echo "  run_cts"
        echo "  run_routing"
        echo "  run_magic"
        echo ""
        docker run -it --rm \
            -v "$DESIGN_DIR:/project" \
            $PDK_MOUNT \
            $IMAGE \
            bash -c "
                volare enable --pdk sky130 2.0.1 || echo 'Using existing PDK'
                cd /project && flow.tcl -interactive
            "
        ;;
    3)
        echo -e "${GREEN}Starting shell...${NC}"
        echo "Inside the shell, run: volare enable --pdk sky130 2.0.1"
        docker run -it --rm \
            -v "$DESIGN_DIR:/project" \
            $PDK_MOUNT \
            $IMAGE \
            bash
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
echo "Results are in: $DESIGN_DIR/runs/"
echo ""
echo "To view results:"
echo "  - Reports: $DESIGN_DIR/runs/<tag>/reports/"
echo "  - Layout: $DESIGN_DIR/runs/<tag>/results/magic/"
echo "  - GDS: $DESIGN_DIR/runs/<tag>/results/final/gds/"
