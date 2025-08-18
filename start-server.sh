#!/bin/bash

# Simple development server script for RadAI Chat
# This script starts a local HTTP server for testing

echo "🏥 Starting RadAI Chat Development Server..."
echo "📱 Mobile-friendly radiology chatbot interface"
echo ""

# Check if Python is available
if command -v python3 &> /dev/null; then
    echo "🐍 Using Python 3 HTTP server"
    echo "🌐 Server will be available at:"
    echo "   Local:    http://localhost:8000"
    echo "   Network:  http://$(hostname -I | awk '{print $1}'):8000"
    echo ""
    echo "📱 For mobile testing, use the network address"
    echo "🛑 Press Ctrl+C to stop the server"
    echo ""
    
    # Start Python HTTP server
    python3 -m http.server 8000
    
elif command -v python &> /dev/null; then
    echo "🐍 Using Python 2 HTTP server"
    echo "🌐 Server will be available at:"
    echo "   Local:    http://localhost:8000"
    echo "   Network:  http://$(hostname -I | awk '{print $1}'):8000"
    echo ""
    echo "📱 For mobile testing, use the network address"
    echo "🛑 Press Ctrl+C to stop the server"
    echo ""
    
    # Start Python 2 HTTP server
    python -m SimpleHTTPServer 8000
    
elif command -v npx &> /dev/null; then
    echo "📦 Using Node.js serve package"
    echo "🌐 Server will be available at:"
    echo "   Local:    http://localhost:8000"
    echo "   Network:  http://$(hostname -I | awk '{print $1}'):8000"
    echo ""
    echo "📱 For mobile testing, use the network address"
    echo "🛑 Press Ctrl+C to stop the server"
    echo ""
    
    # Start Node.js serve
    npx serve . -p 8000
    
else
    echo "❌ No suitable HTTP server found!"
    echo "Please install one of the following:"
    echo "  - Python 3: apt install python3"
    echo "  - Python 2: apt install python"
    echo "  - Node.js: apt install nodejs npm"
    echo ""
    echo "Or manually start your preferred web server in this directory."
fi
