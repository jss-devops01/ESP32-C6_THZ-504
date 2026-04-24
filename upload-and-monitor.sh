#!/bin/bash
#
# ESPHome Upload and Monitor Script for WSL
# Compiles, uploads firmware, and starts monitoring logs
#

# Configuration
CONFIG="${CONFIG:-esp32-c6-thz504.yaml}"
DEVICE="${DEVICE:-192.168.200.80}"
VENV_ACTIVATE="${VENV_ACTIVATE:-/home/jssus/.env/bin/activate}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}ESPHome Upload & Monitor${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Config: ${NC}$CONFIG"
echo -e "${CYAN}Device: ${NC}$DEVICE"
echo ""

# Activate virtual environment
if [ -f "$VENV_ACTIVATE" ]; then
    echo -e "${CYAN}Activating Python virtual environment...${NC}"
    source "$VENV_ACTIVATE"
else
    echo -e "${RED}Error: Virtual environment not found at $VENV_ACTIVATE${NC}"
    exit 1
fi

# Check if esphome is available
if ! command -v esphome &> /dev/null; then
    echo -e "${RED}Error: esphome command not found${NC}"
    echo -e "${RED}Make sure ESPHome is installed in the virtual environment${NC}"
    exit 1
fi

# Compile and upload
echo -e "${CYAN}Compiling and uploading firmware...${NC}"
echo -e "${YELLOW}This may take several minutes...${NC}"
echo ""

esphome run "$CONFIG" --device "$DEVICE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Upload successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${CYAN}Starting log monitoring...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    sleep 2
    
    # Start monitoring logs
    esphome logs "$CONFIG" --device "$DEVICE"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Upload failed!${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
