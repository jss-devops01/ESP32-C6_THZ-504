#!/bin/bash
#
# ESPHome Logs Manager for WSL
# Manages background logging of ESPHome devices
#

# Configuration
CONFIG="${CONFIG:-esp32-c6-thz504.yaml}"
DEVICE="${DEVICE:-192.168.200.80}"
LOG_FILE="${LOG_FILE:-tmp/logs.txt}"
PID_FILE=".esphome.pid"
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

# Functions
show_usage() {
    echo "Usage: $0 {start|stop|status|view|restart|tail}"
    echo ""
    echo "Commands:"
    echo "  start    - Start ESPHome logging in background"
    echo "  stop     - Stop ESPHome logging"
    echo "  status   - Check if logging is running"
    echo "  view     - View logs in real-time (Ctrl+C to exit)"
    echo "  restart  - Restart logging"
    echo "  tail     - Show last 50 lines of log"
    echo ""
    echo "Environment variables:"
    echo "  CONFIG           - YAML config file (default: $CONFIG)"
    echo "  DEVICE           - Device IP or hostname (default: $DEVICE)"
    echo "  LOG_FILE         - Output log file (default: $LOG_FILE)"
    echo "  VENV_ACTIVATE    - Path to Python venv activate script"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 view"
    echo "  CONFIG=esp32-poe-technik.yaml DEVICE=192.168.1.100 $0 start"
}

start_logging() {
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo -e "${YELLOW}ESPHome logging is already running (PID: $pid)${NC}"
            echo -e "${YELLOW}Use 'stop' to stop it first${NC}"
            return 1
        fi
        # Stale PID file
        rm -f "$PID_FILE"
    fi
    
    echo -e "${CYAN}Starting ESPHome logs in background...${NC}"
    echo -e "${CYAN}Config: ${NC}$CONFIG"
    echo -e "${CYAN}Device: ${NC}$DEVICE"
    echo -e "${CYAN}Output: ${NC}$LOG_FILE"
    echo ""
    
    # Activate virtual environment if specified
    if [ -f "$VENV_ACTIVATE" ]; then
        echo -e "${CYAN}Activating Python virtual environment...${NC}"
        source "$VENV_ACTIVATE"
    fi
    
    # Check if esphome is available
    if ! command -v esphome &> /dev/null; then
        echo -e "${RED}Error: esphome command not found${NC}"
        echo -e "${RED}Make sure ESPHome is installed and VENV_ACTIVATE is correct${NC}"
        return 1
    fi
    
    # Start ESPHome logs in background
    nohup esphome logs "$CONFIG" --device "$DEVICE" > "$LOG_FILE" 2>&1 &
    local pid=$!
    
    # Save PID
    echo "$pid" > "$PID_FILE"
    
    # Wait a moment to check if it started successfully
    sleep 2
    
    if ps -p "$pid" > /dev/null 2>&1; then
        echo -e "${GREEN}ESPHome logging started successfully!${NC}"
        echo -e "${GREEN}PID: $pid${NC}"
        echo ""
        echo -e "${CYAN}To view logs:  $0 view${NC}"
        echo -e "${CYAN}To stop:       $0 stop${NC}"
        echo -e "${CYAN}To check:      $0 status${NC}"
    else
        echo -e "${RED}Failed to start ESPHome logging${NC}"
        rm -f "$PID_FILE"
        if [ -f "$LOG_FILE" ]; then
            echo -e "${RED}Last error:${NC}"
            tail -n 10 "$LOG_FILE"
        fi
        return 1
    fi
}

stop_logging() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}No ESPHome logging process found${NC}"
        return 1
    fi
    
    local pid=$(cat "$PID_FILE")
    echo -e "${CYAN}Stopping ESPHome logging process (PID: $pid)...${NC}"
    
    # Try graceful kill first
    kill "$pid" 2>/dev/null
    sleep 1
    
    # Check if really stopped
    if ps -p "$pid" > /dev/null 2>&1; then
        echo -e "${YELLOW}Process still running, forcing kill...${NC}"
        kill -9 "$pid" 2>/dev/null
    fi
    
    rm -f "$PID_FILE"
    echo -e "${GREEN}ESPHome logging stopped${NC}"
}

check_status() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}ESPHome logging is NOT running${NC}"
        return 1
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if ps -p "$pid" > /dev/null 2>&1; then
        echo -e "${GREEN}ESPHome logging IS running${NC}"
        echo -e "${GREEN}PID: $pid${NC}"
        echo ""
        echo -e "${CYAN}Process info:${NC}"
        ps -f -p "$pid"
        echo ""
        if [ -f "$LOG_FILE" ]; then
            local size=$(stat -c%s "$LOG_FILE" 2>/dev/null || stat -f%z "$LOG_FILE" 2>/dev/null || echo "0")
            local lines=$(wc -l < "$LOG_FILE")
            local size_kb=$((size / 1024))
            echo -e "${CYAN}Log file: $LOG_FILE (${size_kb} KB, ${lines} lines)${NC}"
        fi
    else
        echo -e "${YELLOW}ESPHome logging is NOT running (stale PID file)${NC}"
        rm -f "$PID_FILE"
        return 1
    fi
}

view_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "${RED}Log file not found: $LOG_FILE${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Showing logs (Ctrl+C to exit)...${NC}"
    echo ""
    tail -f "$LOG_FILE"
}

tail_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "${RED}Log file not found: $LOG_FILE${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Last 50 lines of $LOG_FILE:${NC}"
    echo ""
    tail -n 50 "$LOG_FILE"
}

restart_logging() {
    echo -e "${CYAN}Restarting ESPHome logging...${NC}"
    stop_logging
    sleep 1
    start_logging
}

# Main execution
case "${1:-}" in
    start)
        start_logging
        ;;
    stop)
        stop_logging
        ;;
    status)
        check_status
        ;;
    view)
        view_logs
        ;;
    tail)
        tail_logs
        ;;
    restart)
        restart_logging
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
