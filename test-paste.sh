#!/bin/bash

echo "🧪 Testing RadAI Chat Paste Functionality"
echo "=========================================="

echo "📋 Checking paste event handlers in JavaScript..."

# Check if paste handlers exist
if grep -q "setupGlobalPaste" script.js; then
    echo "✅ Global paste handler found"
else
    echo "❌ Global paste handler missing"
fi

if grep -q "addEventListener('paste'" script.js; then
    echo "✅ Paste event listeners found"
    grep -n "addEventListener('paste'" script.js
else
    echo "❌ Paste event listeners missing"
fi

echo ""
echo "🔧 Cache-busting version:"
grep -n "script.js?v=" index.html

echo ""
echo "📝 Instructions for testing:"
echo "1. Open https://radiology.haydd.com (or http://localhost:5000)"
echo "2. Take a screenshot (Print Screen)"
echo "3. Click anywhere in the chat area"  
echo "4. Press Ctrl+V (or Cmd+V on Mac)"
echo "5. You should see: 'Image pasted successfully! 📋🖼️'"

echo ""
echo "🐛 If paste doesn't work:"
echo "- Check browser console (F12) for errors"
echo "- Try hard refresh (Ctrl+Shift+R)"
echo "- Ensure image is in clipboard before pasting"

echo ""
echo "✨ Test complete!"
