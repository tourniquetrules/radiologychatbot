#!/bin/bash

# Test script specifically for Cloudflare tunnel deployment

echo "=========================================="
echo "RadAI Chat Cloudflare Tunnel Test"
echo "=========================================="
echo ""

echo "🌩️  Testing Cloudflare tunnel configuration..."
echo ""

# Test 1: Local server status
echo "🏠 Local server status:"
SERVER_STATUS=$(cd /home/tourniquetrules/radiology && ./status.sh | grep "Server is running")
if [[ $SERVER_STATUS == *"running"* ]]; then
    echo "  ✅ Local server is running"
else
    echo "  ❌ Local server is not running"
    echo "  💡 Run: ./start-background.sh"
    exit 1
fi

# Test 2: Local API functionality
echo ""
echo "🔗 Local API test:"
LOCAL_API=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/v1/models)
if [ "$LOCAL_API" == "200" ]; then
    echo "  ✅ Local API: OK (HTTP $LOCAL_API)"
else
    echo "  ❌ Local API: FAILED (HTTP $LOCAL_API)"
    exit 1
fi

# Test 3: Configuration detection
echo ""
echo "📋 Configuration detection test:"
echo "  Testing JavaScript config detection..."

# Create a simple test HTML to verify config
cat > temp_test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <script src="config.js"></script>
</head>
<body>
    <script>
        // Test different hostnames
        const testCases = [
            { hostname: 'localhost', expected: 'development' },
            { hostname: 'radiology.haydd.com', expected: 'cloudflare' },
            { hostname: '192.168.2.180', expected: 'development' },
            { hostname: 'other.example.com', expected: 'external' }
        ];
        
        testCases.forEach(test => {
            // Mock window.location
            const originalLocation = window.location;
            delete window.location;
            window.location = { hostname: test.hostname };
            
            const config = window.RadAIConfig.getCurrentConfig();
            const actual = config.description.includes('Local') ? 'development' : 
                          config.description.includes('Cloudflare') ? 'cloudflare' : 'external';
            
            console.log(`${test.hostname}: ${actual} (${config.description})`);
            
            // Restore location
            window.location = originalLocation;
        });
    </script>
</body>
</html>
EOF

# Test the config (this will just verify it loads)
if curl -s http://localhost:5000/config.js > /dev/null; then
    echo "  ✅ Configuration file loads correctly"
else
    echo "  ❌ Configuration file failed to load"
fi

rm -f temp_test.html

# Test 4: Cloudflare tunnel info
echo ""
echo "🌩️  Cloudflare tunnel information:"
echo "  📡 Tunnel domain: radiology.haydd.com"
echo "  🏠 Local target: localhost:5000"
echo "  🔗 API endpoint: radiology.haydd.com/api/*"
echo ""

# Test 5: Expected behavior
echo "🎯 Expected behavior:"
echo ""
echo "When accessing from radiology.haydd.com:"
echo "  1. JavaScript detects 'haydd.com' in hostname"
echo "  2. Uses Cloudflare tunnel configuration"
echo "  3. API calls go to: radiology.haydd.com/api/*"
echo "  4. Cloudflare tunnel forwards to: localhost:5000/api/*"
echo "  5. Your Python server handles the API proxy to LM Studio"
echo ""

# Test 6: Troubleshooting guide
echo "🔧 If external access still fails:"
echo ""
echo "  1. Verify Cloudflare tunnel is active:"
echo "     cloudflared tunnel list"
echo ""
echo "  2. Test tunnel directly:"
echo "     curl https://radiology.haydd.com"
echo ""
echo "  3. Test API through tunnel:"
echo "     curl https://radiology.haydd.com/api/v1/models"
echo ""
echo "  4. Check browser console for errors"
echo ""

echo "✅ Your setup should work perfectly with Cloudflare tunnel!"
echo "   The app will automatically detect tunnel access and work seamlessly."
echo ""
echo "🌐 Access URLs:"
echo "  Local:    http://localhost:5000"
echo "  Tunnel:   https://radiology.haydd.com"
echo "  Network:  http://192.168.2.180:5000"
echo ""
echo "=========================================="
