#!/bin/bash

# RadAI Chat Server Management Script
# Stop the background server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/radai_server.pid"

echo "=============================="
echo "RadAI Chat - Stopping Server"
echo "=============================="

if [ ! -f "$PID_FILE" ]; then
    echo "❌ No PID file found. Server may not be running."
    echo "   Checking for any running RadAI servers..."
    
    # Try to find and kill any running server processes
    PIDS=$(ps aux | grep "python3 server.py" | grep -v grep | awk '{print $2}')
    if [ ! -z "$PIDS" ]; then
        echo "🔍 Found running server processes: $PIDS"
        echo "🛑 Stopping them..."
        kill $PIDS
        sleep 2
        echo "✅ Server processes stopped"
    else
        echo "ℹ️  No running server processes found"
    fi
    exit 0
fi

PID=$(cat "$PID_FILE")

if ps -p $PID > /dev/null 2>&1; then
    echo "🛑 Stopping server (PID: $PID)..."
    kill $PID
    
    # Wait for graceful shutdown
    for i in {1..10}; do
        if ! ps -p $PID > /dev/null 2>&1; then
            echo "✅ Server stopped successfully"
            rm -f "$PID_FILE"
            exit 0
        fi
        sleep 1
    done
    
    # Force kill if still running
    if ps -p $PID > /dev/null 2>&1; then
        echo "⚠️  Forcing server shutdown..."
        kill -9 $PID
        sleep 1
        if ! ps -p $PID > /dev/null 2>&1; then
            echo "✅ Server force-stopped"
        else
            echo "❌ Failed to stop server"
            exit 1
        fi
    fi
else
    echo "ℹ️  Server (PID: $PID) is not running"
fi

rm -f "$PID_FILE"
echo "🧹 Cleaned up PID file"
