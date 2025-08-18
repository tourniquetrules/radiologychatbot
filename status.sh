#!/bin/bash

# RadAI Chat Server Management Script
# Check server status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/radai_server.pid"

echo "=============================="
echo "RadAI Chat - Server Status"
echo "=============================="

# Check if PID file exists
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "📄 PID file exists: $PID"
    
    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ Server is running (PID: $PID)"
        
        # Get process details
        echo ""
        echo "📊 Process Details:"
        ps -p $PID -o pid,ppid,cmd,etime,pcpu,pmem
        
        # Test server response
        echo ""
        echo "🌐 Testing server response..."
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000)
        if [ "$HTTP_CODE" == "200" ]; then
            echo "✅ Server responding correctly (HTTP $HTTP_CODE)"
            echo "   URL: http://localhost:5000"
            echo "   Network: http://$(hostname -I | awk '{print $1}'):5000"
        else
            echo "⚠️  Server not responding properly (HTTP $HTTP_CODE)"
        fi
        
        # Show recent log entries
        echo ""
        echo "📝 Recent log entries:"
        if [ -f "$SCRIPT_DIR/radai_server.log" ]; then
            tail -n 5 "$SCRIPT_DIR/radai_server.log"
        else
            echo "   No log file found"
        fi
        
    else
        echo "❌ Server not running (stale PID file)"
        echo "🧹 Cleaning up stale PID file..."
        rm -f "$PID_FILE"
    fi
else
    echo "❌ No PID file found"
    
    # Check for any running server processes
    PIDS=$(ps aux | grep "python3 server.py" | grep -v grep | awk '{print $2}')
    if [ ! -z "$PIDS" ]; then
        echo "⚠️  Found running server processes without PID file:"
        ps aux | grep "python3 server.py" | grep -v grep
        echo ""
        echo "💡 Consider using './stop-server.sh' to clean up"
    else
        echo "ℹ️  No server processes found"
        echo ""
        echo "💡 Use './start-background.sh' to start the server"
    fi
fi

echo ""
echo "🔧 Available commands:"
echo "   ./start-background.sh  - Start server in background"
echo "   ./stop-server.sh       - Stop the server"
echo "   ./logs.sh              - View server logs"
