#!/bin/bash

# Quick diagnostic script for RadAI Chat issues
# Usage: ./diagnose.sh

echo "🔍 RadAI Chat Diagnostic Tool"
echo "=================================="

# Check local server
echo "1️⃣  Checking local server..."
if curl -s http://localhost:5000 > /dev/null; then
    echo "✅ Local server responding on port 5000"
else
    echo "❌ Local server not responding"
    echo "   Run: ./start-background.sh"
    exit 1
fi

# Check API proxy
echo ""
echo "2️⃣  Checking API proxy..."
API_RESPONSE=$(curl -s http://localhost:5000/api/v1/models)
if echo "$API_RESPONSE" | grep -q '"data"'; then
    MODEL_COUNT=$(echo "$API_RESPONSE" | grep -o '"id"' | wc -l)
    echo "✅ API proxy working - $MODEL_COUNT models available"
else
    echo "❌ API proxy failing"
    echo "   Check LM Studio at 192.168.2.64:1234"
fi

# Check configuration
echo ""
echo "3️⃣  Checking configuration..."
if [ -f "config.js" ]; then
    echo "✅ Configuration file exists"
    if grep -q "haydd.com" config.js; then
        echo "✅ Cloudflare tunnel detection configured"
    else
        echo "⚠️  No Cloudflare tunnel detection found"
    fi
else
    echo "❌ Configuration file missing"
fi

# Test Cloudflare tunnel (if accessible)
echo ""
echo "4️⃣  Testing Cloudflare tunnel..."
if curl -s --max-time 10 https://radiology.haydd.com > /dev/null 2>&1; then
    echo "✅ radiology.haydd.com is accessible"
    
    # Test API through tunnel
    TUNNEL_API=$(curl -s --max-time 10 https://radiology.haydd.com/api/v1/models)
    if echo "$TUNNEL_API" | grep -q '"data"'; then
        echo "✅ API working through Cloudflare tunnel"
    else
        echo "❌ API failing through tunnel"
        echo "   Check tunnel configuration"
    fi
else
    echo "⚠️  radiology.haydd.com not accessible (normal if tunnel is down)"
fi

# Check processes
echo ""
echo "5️⃣  Checking running processes..."
PYTHON_PROCS=$(ps aux | grep "python.*server.py" | grep -v grep | wc -l)
echo "📊 Python server processes: $PYTHON_PROCS"

if [ "$PYTHON_PROCS" -gt 1 ]; then
    echo "⚠️  Multiple server processes detected"
    echo "   Consider: ./stop-server.sh && ./start-background.sh"
fi

# Summary
echo ""
echo "📋 Summary"
echo "==========="
echo "Local Access: http://localhost:5000"
echo "Network Access: http://192.168.2.180:5000"
echo "Internet Access: https://radiology.haydd.com"
echo ""
echo "For issues, check:"
echo "- LM Studio running on 192.168.2.64:1234"
echo "- Cloudflare tunnel active"
echo "- Browser console for JavaScript errors"

echo ""
echo "✨ Diagnostic complete!"
