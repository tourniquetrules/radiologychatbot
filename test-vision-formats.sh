#!/bin/bash

echo "🧪 Testing LM Studio Vision API Formats"
echo "========================================"

# Test 1: Simple text-only request
echo "📝 Test 1: Text-only request..."
curl -s -X POST "http://192.168.2.64:1234/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "medgemma-4b-it",
    "messages": [
      {"role": "system", "content": "You are a medical AI assistant."},
      {"role": "user", "content": "Hello, can you analyze medical images?"}
    ],
    "max_tokens": 100
  }' | jq -r '.choices[0].message.content'

echo ""
echo "📋 Available image formats to test:"
echo "1. OpenAI Vision API format (content array)"
echo "2. Embedded base64 in text" 
echo "3. Direct image_url parameter"
echo "4. LM Studio specific format"

echo ""
echo "💡 Next: Check LM Studio documentation or try different formats"
echo "   The model clearly supports vision when used directly in LM Studio"
