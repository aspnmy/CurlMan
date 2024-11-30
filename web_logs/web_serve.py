#!/usr/bin/env python3
import http.server
import socketserver

PORT = 7988

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    print("Go to http://localhost:{PORT}/content.json to view the file.")
    httpd.serve_forever()