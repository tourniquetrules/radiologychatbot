#!/bin/bash

# Test script to verify external deployment readiness

echo "=========================================="
echo "RadAI Chat External Deployment Test"
echo "=========================================="
echo ""

# Test 1: Check if all required files exist
echo "📁 Checking required files..."
files=("index.html" "styles.css" "script.js" "config.js" "manifest.json" "sw.js" "api.php")
missing_files=()

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (MISSING)"
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo ""
    echo "❌ Missing files detected. Please ensure all files are present."
    exit 1
fi

echo ""
echo "📡 Testing LM Studio connectivity from different perspectives..."

# Test 2: Test direct LM Studio connection
echo "🔗 Testing direct LM Studio connection..."
LM_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.2.64:1234/v1/models)
if [ "$LM_RESPONSE" == "200" ]; then
    echo "  ✅ Direct LM Studio: OK (HTTP $LM_RESPONSE)"
else
    echo "  ❌ Direct LM Studio: FAILED (HTTP $LM_RESPONSE)"
    echo "     This may affect external access"
fi

# Test 3: Test local proxy
echo "🏠 Testing local proxy..."
LOCAL_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/v1/models)
if [ "$LOCAL_RESPONSE" == "200" ]; then
    echo "  ✅ Local proxy: OK (HTTP $LOCAL_RESPONSE)"
else
    echo "  ❌ Local proxy: FAILED (HTTP $LOCAL_RESPONSE)"
fi

# Test 4: Simulate PHP proxy behavior
echo "📄 Testing PHP proxy simulation..."
php -r "
    \$url = 'http://192.168.2.64:1234/v1/models';
    \$context = stream_context_create([
        'http' => [
            'method' => 'GET',
            'timeout' => 10,
            'header' => 'Content-Type: application/json'
        ]
    ]);
    
    \$result = @file_get_contents(\$url, false, \$context);
    if (\$result !== false) {
        \$data = json_decode(\$result, true);
        if (isset(\$data['data'])) {
            echo '  ✅ PHP can reach LM Studio (' . count(\$data['data']) . ' models)' . PHP_EOL;
        } else {
            echo '  ❌ PHP got invalid response from LM Studio' . PHP_EOL;
        }
    } else {
        echo '  ❌ PHP cannot reach LM Studio' . PHP_EOL;
    }
" 2>/dev/null || echo "  ⚠️  PHP test skipped (PHP not available)"

echo ""
echo "📋 Deployment Checklist:"
echo ""
echo "For external deployment (radiology.haydd.com):"
echo "  1. Upload all files to your web server"
echo "  2. Ensure PHP is enabled on the server"
echo "  3. Verify external server can reach 192.168.2.64:1234"
echo "  4. Test: https://radiology.haydd.com/api.php?path=v1/models"
echo ""
echo "🔧 Files ready for upload:"
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        size=$(du -h "$file" | cut -f1)
        echo "  📄 $file ($size)"
    fi
done

echo ""
echo "🌐 Access URLs:"
echo "  Local:    http://localhost:5000"
echo "  Network:  http://$(hostname -I | awk '{print $1}'):5000"
echo "  External: https://radiology.haydd.com (after upload)"
echo ""
echo "=========================================="
