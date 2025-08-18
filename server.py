#!/usr/bin/env python3
"""
RadAI Chat Server with LM Studio Proxy
Serves static files and proxies API requests to LM Studio
"""

import os
import sys
import json
import requests
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

# LM Studio configuration
LM_STUDIO_BASE_URL = "http://192.168.2.64:1234"

class RadAIRequestHandler(SimpleHTTPRequestHandler):
    """HTTP request handler with CORS support and LM Studio proxy"""
    
    def end_headers(self):
        """Add CORS headers to all responses"""
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.send_header('Access-Control-Max-Age', '86400')
        super().end_headers()
    
    def do_OPTIONS(self):
        """Handle preflight requests"""
        self.send_response(200)
        self.end_headers()
    
    def do_GET(self):
        """Handle GET requests, proxy API calls to LM Studio or serve static files"""
        parsed_path = urlparse(self.path)
        
        # Check if this is an API request
        if parsed_path.path.startswith('/api/'):
            self.handle_api_request(parsed_path.path[5:])  # Remove '/api/' prefix
        else:
            # Serve static files
            super().do_GET()
    
    def do_POST(self):
        """Handle POST requests, proxy API calls to LM Studio"""
        parsed_path = urlparse(self.path)
        
        # Check if this is an API request
        if parsed_path.path.startswith('/api/'):
            self.handle_api_request(parsed_path.path[5:])  # Remove '/api/' prefix
        else:
            # For non-API POST requests, return 405 Method Not Allowed
            self.send_response(405)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Method Not Allowed')
    
    def handle_api_request(self, api_path):
        """Proxy API requests to LM Studio"""
        try:
            # Read request body for POST requests
            content_length = int(self.headers.get('Content-Length', 0))
            request_body = self.rfile.read(content_length) if content_length > 0 else b''
            
            # Construct LM Studio URL
            lm_studio_url = f"{LM_STUDIO_BASE_URL}/{api_path}"
            
            # Prepare headers for LM Studio request
            headers = {
                'Content-Type': 'application/json',
                'User-Agent': 'RadAI-Chat/1.0'
            }
            
            print(f"[API] {self.command} {api_path} -> {lm_studio_url}")
            
            # Make request to LM Studio based on method
            if self.command == 'POST' and request_body:
                response = requests.post(
                    lm_studio_url,
                    data=request_body,
                    headers=headers,
                    timeout=60
                )
            else:
                response = requests.get(lm_studio_url, headers=headers, timeout=10)
            
            # Send response back to client
            self.send_response(response.status_code)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            self.wfile.write(response.content)
            
            print(f"[API] Response: {response.status_code} ({len(response.content)} bytes)")
            
        except requests.exceptions.RequestException as e:
            print(f"[API] Error connecting to LM Studio: {e}")
            self.send_response(502)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            error_response = {
                "error": {
                    "message": f"Failed to connect to LM Studio: {str(e)}",
                    "type": "connection_error"
                }
            }
            self.wfile.write(json.dumps(error_response).encode())
            
        except Exception as e:
            print(f"[API] Unexpected error: {e}")
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            error_response = {
                "error": {
                    "message": f"Internal server error: {str(e)}",
                    "type": "server_error"
                }
            }
            self.wfile.write(json.dumps(error_response).encode())
    
    def guess_type(self, path):
        """Guess the type of a file with additional MIME types"""
        mime_type = super().guess_type(path)
        
        # Add specific MIME types for web app files
        if path.endswith('.js'):
            return 'application/javascript'
        elif path.endswith('.css'):
            return 'text/css'
        elif path.endswith('.json'):
            return 'application/json'
        elif path.endswith('.svg'):
            return 'image/svg+xml'
        elif path.endswith('.webp'):
            return 'image/webp'
        
        return mime_type
    
    def log_message(self, format, *args):
        """Custom log format"""
        print(f"[{self.log_date_time_string()}] {format % args}")

def main():
    """Main server function"""
    # Change to the directory containing this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    port = 5000
    
    print("=" * 60)
    print("RadAI Chat Development Server with LM Studio Proxy")
    print("=" * 60)
    print(f"Server URL: http://localhost:{port}")
    print(f"Server URL: http://127.0.0.1:{port}")
    print(f"LM Studio: {LM_STUDIO_BASE_URL}")
    print(f"Serving from: {script_dir}")
    print("-" * 60)
    print("Files being served:")
    
    # List the files in the current directory
    for file in sorted(os.listdir('.')):
        if os.path.isfile(file) and not file.startswith('.'):
            file_size = os.path.getsize(file)
            print(f"  {file} ({file_size:,} bytes)")
    
    print("-" * 60)
    print("API Endpoints:")
    print("  /api/v1/models           - List available models")
    print("  /api/v1/chat/completions - Chat completions")
    print("-" * 60)
    print("Press Ctrl+C to stop the server")
    print("=" * 60)
    
    try:
        # Test LM Studio connectivity
        response = requests.get(f"{LM_STUDIO_BASE_URL}/v1/models", timeout=5)
        print(f"✅ LM Studio connectivity test: HTTP {response.status_code}")
    except Exception as e:
        print(f"⚠️  LM Studio connectivity test failed: {e}")
        print("   The server will still start, but API calls may fail")
    
    print("=" * 60)
    
    try:
        # Create and start the server
        httpd = HTTPServer(('', port), RadAIRequestHandler)
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n" + "=" * 60)
        print("Server shutting down...")
        print("=" * 60)
        httpd.shutdown()
    except OSError as e:
        if e.errno == 98:  # Address already in use
            print(f"Error: Port {port} is already in use.")
            print("Please stop any other servers running on this port or choose a different port.")
            sys.exit(1)
        else:
            print(f"Error starting server: {e}")
            sys.exit(1)

if __name__ == '__main__':
    main()
