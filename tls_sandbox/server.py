import ssl
from http.server import HTTPServer, SimpleHTTPRequestHandler

TLS_PORT = 4443
FILES = {"certfile": "server.crt", "keyfile": "server.key"}

# Configure the HTTPS server
server_address = ("localhost", TLS_PORT)
httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)

# Load the certificate and private key
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile=FILES["certfile"], keyfile=FILES["keyfile"])

# Wrap the server socket with SSL
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"HTTPS server running at https://localhost:{TLS_PORT}/")
httpd.serve_forever()
