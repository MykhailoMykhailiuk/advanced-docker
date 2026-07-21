# app.py
from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"hello docker")

def run(host="0.0.0.0", port=8000):
    server = HTTPServer((host, port), Handler)
    server.serve_forever()

if __name__ == "__main__":
    run()