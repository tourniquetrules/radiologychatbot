#!/bin/bash

# RadAI Chat Server Management Script
# Start the server in background mode

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/radai_server.log"
PID_FILE="$SCRIPT_DIR/radai_server.pid"

echo "=============================="
echo "RadAI Chat - Starting Server"
echo "=============================="

# Check if server is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "❌ Server is already running (PID: $PID)"
        echo "   Use './stop-server.sh' to stop it first"
        exit 1
    else
        echo "🧹 Removing stale PID file..."
        rm -f "$PID_FILE"
    fi
fi

# Start the server in background
echo "🚀 Starting RadAI Chat server in background..."
cd "$SCRIPT_DIR"
nohup python3 server.py > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

# Save the PID
echo $SERVER_PID > "$PID_FILE"

# Wait a moment and check if it started successfully
sleep 2
if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo "✅ Server started successfully!"
    echo "   PID: $SERVER_PID"
    echo "   URL: http://localhost:5000"
    echo "   Log: $LOG_FILE"
    echo ""
    echo "📱 For mobile access use: http://$(hostname -I | awk '{print $1}'):5000"
    echo ""
    echo "🔧 Management commands:"
    echo "   ./stop-server.sh  - Stop the server"
    echo "   ./status.sh       - Check server status"
    echo "   ./logs.sh         - View server logs"
else
    echo "❌ Failed to start server"
    rm -f "$PID_FILE"
    exit 1
fi
