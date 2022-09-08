import os
import sys
import json
import requests
import datetime
from io import BytesIO
from http.server import HTTPServer, BaseHTTPRequestHandler

HOST_NAME = "0.0.0.0"
PORT = 8080
SMS_GATE_API = "https://api.sms.example.org/api/v1.1"
SMS_GATE_LOGIN = os.environ['SMS_GATE_LOGIN']
SMS_GATE_PASSWORD = os.environ['SMS_GATE_PASSWORD']

def send(data):
    url = SMS_GATE_API + "/sms/outgoing"
    response = requests.post(url, data=data, auth=(SMS_GATE_LOGIN, SMS_GATE_PASSWORD), headers={"Content-Type": "application/json", "charset": "UTF-8"})
    dt = datetime.datetime.now()
    print(dt, response.text)
    return response

class PythonHTTPServer(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200, "OK")
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(b"Python HTTP server for send SMS via SMS Gate")

    def do_POST(self):
        try:
            if self.path == "/":
                content_length = int(self.headers["Content-Length"])
                data_in = self.rfile.read(content_length)
                data_json = json.loads(data_in)
                data_out = json.dumps(data_json)
                self.send_response(200, "OK")
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(data_out.encode(encoding="utf-8"))

            if self.path == "/send/jz28xqpd-mif7-7m2x-zjcq-k7tgd6rj148j":
                content_length = int(self.headers["Content-Length"])
                data_in = self.rfile.read(content_length)
                data_json = json.loads(data_in)
                data_out = json.dumps(data_json)
                response = send(data=data_out)
                self.send_response(response.status_code)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(response.json()).encode(encoding="utf-8"))

        except Exception as err:
            self.send_response(400, "Bad Content")
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            response = BytesIO()
            response.write(b"Error: ")
            response.write(bytes(str(err), encoding="utf-8"))
            self.wfile.write(response.getvalue())

if __name__ == "__main__":
    server = HTTPServer((HOST_NAME, PORT), PythonHTTPServer)
    dt = datetime.datetime.now()
    print(dt, f"Server started http://{HOST_NAME}:{PORT}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.server_close()
        dt = datetime.datetime.now()
        print(dt, "Server stopped successfully")
        sys.exit(0)
