from http.server import HTTPServer, BaseHTTPRequestHandler
import argparse

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        message = f"""
        <html>
        <head><title>Skyward DevOps Challenge</title></head>
        <body>
            <h1>Hello from the Skyward DevOps Challenge!</h1>
            <p>This is your server response.</p>
        </body>
        </html>
        """
        self.wfile.write(message.encode('utf-8'))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Python Web Server')
    parser.add_argument('--host', default='0.0.0.0', help='Host to listen on')
    parser.add_argument('--port', type=int, default=8000, help='Port to listen on')
    args = parser.parse_args()

    server_address = (args.host, args.port)
    httpd = HTTPServer(server_address, SimpleHandler)
    print(f"[INFO]: Webserver listening: http://{args.host}:{args.port}")
    httpd.serve_forever()
