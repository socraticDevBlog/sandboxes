import requests # type: ignore

# Disable warnings for self-signed certificates (for sandbox purposes only)
import urllib3

TLS_PORT = 4443
RESPONSE_HTML_FILENAME = "response.html"
CERT_FILE = "server.crt"


urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

try:
    response = requests.get(f"https://localhost:{TLS_PORT}", verify=CERT_FILE)
except Exception as e:
    print("error occurred:", e)
    exit(1)
print("Server response:", response.text)

with open(RESPONSE_HTML_FILENAME, "w") as html_file:
    html_file.write(response.text)

print(f"Server response saved to {RESPONSE_HTML_FILENAME}")
