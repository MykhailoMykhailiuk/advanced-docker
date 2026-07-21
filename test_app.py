# test_app.py
import threading
import time
import urllib.request
from http.server import HTTPServer
from app import Handler

def test_hello_docker_response():
    server = HTTPServer(("127.0.0.1", 0), Handler)  # port 0 = pick a free port
    port = server.server_address[1]

    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    time.sleep(0.2)  # give the server a moment to start

    try:
        response = urllib.request.urlopen(f"http://127.0.0.1:{port}")
        assert response.status == 200
        assert response.read() == b"hello docker"
    finally:
        server.shutdown()
        thread.join()