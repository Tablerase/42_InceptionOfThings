from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8000
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()
        self.wfile.write(b"Hello from MY-APP!\n")
httpd = HTTPServer(("", PORT), Handler)
print(f"Serving MY-APP on port {PORT}")
httpd.serve_forever()
