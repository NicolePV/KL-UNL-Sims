#!/usr/local/bin/python3

# 
# HTTP server with custom SSI implementation 
# (covering simple .shtml file directives like <!--#include file="..." -->)
# 

import http.server
import socketserver
import os
import re

PORT = 8000

class SSIHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Only process .shtml files
        if self.path.endswith(".shtml"):
            file_path = self.translate_path(self.path)
            if os.path.exists(file_path):
                self.send_response(200)
                self.send_header("Content-type", "text/html")
                self.end_headers()
                
                with open(file_path, 'r') as f:
                    content = f.read()
                    # Simple regex for SSI #include
                    processed = re.sub(
                        r'<!--#include (?:file|virtual)="([^"]+)"-->',
                        self.replace_ssi,
                        content
                    )
                    self.wfile.write(processed.encode('utf-8'))
                return
        return super().do_GET()

    def replace_ssi(self, match):
        inc_file = match.group(1)
        # Security: strictly serve from the current directory
        inc_path = os.path.join(os.getcwd(), inc_file)
        if os.path.exists(inc_path):
            with open(inc_path, 'r') as f:
                return f.read()
        return f"<!-- SSI Error: {inc_file} not found -->"

with socketserver.TCPServer(("", PORT), SSIHandler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()

