#!/bin/bash

# RadAI Chat Server Management Script
# View server logs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/radai_server.log"

echo "=============================="
echo "RadAI Chat - Server Logs"
echo "=============================="

if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Log file not found: $LOG_FILE"
    echo "   Server may not be running or hasn't been started in background mode"
    exit 1
fi

echo "📁 Log file: $LOG_FILE"
echo "📊 Log size: $(du -h "$LOG_FILE" | cut -f1)"
echo ""

# Check command line argument for how many lines to show
LINES=${1:-20}

if [ "$1" == "follow" ] || [ "$1" == "-f" ]; then
    echo "👀 Following log file (Ctrl+C to stop)..."
    echo "----------------------------------------"
    tail -f "$LOG_FILE"
elif [ "$1" == "all" ]; then
    echo "📜 Full log content:"
    echo "----------------------------------------"
    cat "$LOG_FILE"
else
    echo "📝 Last $LINES log entries:"
    echo "----------------------------------------"
    tail -n "$LINES" "$LOG_FILE"
    echo ""
    echo "💡 Usage:"
    echo "   ./logs.sh         - Show last 20 lines"
    echo "   ./logs.sh 50      - Show last 50 lines" 
    echo "   ./logs.sh all     - Show entire log"
    echo "   ./logs.sh follow  - Follow log in real-time"
fi
