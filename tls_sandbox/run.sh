#!/bin/sh

KEY_FILE=server.key
CERT_FILE=server.crt
EXPIRES_IN=365

openssl genpkey -algorithm RSA -out $KEY_FILE -pkeyopt rsa_keygen_bits:2048

openssl req -new -x509 -key $KEY_FILE -out $CERT_FILE -days $EXPIRES_IN \
    -config openssl.cnf

python server.py &
SERVER_PID=$!

python -m venv env
# shellcheck source=/dev/null
. env/bin/activate

pip install -r requirements.txt

python client.py

open response.html

kill $SERVER_PID
