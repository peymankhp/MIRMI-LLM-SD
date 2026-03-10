#!/bin/bash
# Quick start script for web interfaces

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        Ollama Web Interface - Quick Start                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if Ollama is accessible
echo "Checking Ollama API..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✅ Ollama API is accessible"
else
    echo "❌ Ollama API is not accessible"
    echo "Please make sure Ollama is running:"
    echo "  docker ps | grep ollama"
    exit 1
fi
echo ""

# Show available options
echo "Choose how to access the web interface:"
echo ""
echo "1. HTML Interface (Simple - No installation)"
echo "   - Just opens in your browser"
echo "   - No setup required"
echo ""
echo "2. Flask Web App (Advanced - Requires Flask)"
echo "   - Server-based"
echo "   - Can be accessed from other devices"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo ""
        echo "Opening HTML interface in your browser..."
        
        # Try different browsers
        if command -v xdg-open > /dev/null; then
            xdg-open web-interface.html
        elif command -v firefox > /dev/null; then
            firefox web-interface.html &
        elif command -v google-chrome > /dev/null; then
            google-chrome web-interface.html &
        elif command -v chromium-browser > /dev/null; then
            chromium-browser web-interface.html &
        else
            echo "Could not detect browser. Please open web-interface.html manually."
            echo "File location: $(pwd)/web-interface.html"
        fi
        
        echo ""
        echo "✅ HTML interface should open in your browser"
        echo ""
        echo "If it didn't open automatically, open this file in your browser:"
        echo "  $(pwd)/web-interface.html"
        ;;
        
    2)
        echo ""
        echo "Starting Flask web app..."
        
        # Check if Flask is installed
        if ! python3 -c "import flask" 2>/dev/null; then
            echo "Flask is not installed. Installing..."
            pip3 install flask requests
        fi
        
        echo ""
        echo "Starting server..."
        echo "Press Ctrl+C to stop"
        echo ""
        
        python3 web_app.py
        ;;
        
    *)
        echo "Invalid choice. Please run the script again and choose 1 or 2."
        exit 1
        ;;
esac
