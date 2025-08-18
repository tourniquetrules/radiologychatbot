#!/bin/bash

# RadAI Chat Server Startup Script
# This script starts the development server on port 5000

echo "=============================="
echo "RadAI Chat Server"
echo "=============================="
echo ""

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    echo "Starting Python server on port 5000..."
    echo "Navigate to: http://localhost:5000"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    python3 server.py
elif command -v node &> /dev/null; then
    echo "Python 3 not found, starting Node.js server on port 5000..."
    echo "Navigate to: http://localhost:5000"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    node server.js
else
    echo "Error: Neither Python 3 nor Node.js found!"
    echo "Please install Python 3 or Node.js to run the server."
    exit 1
fi
