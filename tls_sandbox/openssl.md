# openssl

OpenSSL is a cryptography toolkit implementing the Secure Sockets Layer (SSL)
and Transport Layer Security (TLS) network protocols and related cryptography
standards required by them.

The openssl program is a command line program for using the various cryptography functions of OpenSSL's crypto library
from the shell.  It can be used for

- Creation and management of private keys, public keys and parameters
- Public key cryptographic operations
- Creation of X.509 certificates, CSRs and CRLs
- Calculation of Message Digests and Message Authentication Codes
- Encryption and Decryption with Ciphers
- SSL/TLS Client and Server Tests
- Handling of S/MIME signed or encrypted mail
- Timestamp requests, generation and verification

## genpkey

Generation of Private Key

provide a _public key algorithm_ using flag `-algorithm <val>`

we are using `RSA` here. if you want what's available execute command `openssl
list -public-key-algorithms`

key size is inputted like this: `-pkeyopt rsa_keygen_bits:2048`

## req

req PKCS#10 X.509 Certificate Signing Request (CSR) Management

The private key is used to sign the Certificate Signing Request (CSR) or the certificate itself (in the case of a self-signed certificate). This proves ownership of the corresponding public key.

## glossary

### PKCS: Public Key Cryptography Standards

PKCS stands for Public Key Cryptography Standards. These are a series of standards developed by RSA Laboratories to promote interoperability among public key cryptography systems.

Key PKCS Standards:
- PKCS#1: Specifies the format for RSA keys and encryption/signature schemes.
- PKCS#7: Defines the format for cryptographic messages, often used for digital signatures and encryption.
- PKCS#10: Specifies the format for Certificate Signing Requests (CSRs).
- PKCS#12: Defines a format for securely storing certificates and private keys (commonly used in .p12 or .pfx files).
In the context of your file, PKCS#10 is used for managing Certificate Signing
Requests (CSRs).

### Certificate Signing Request (CSR)

A Certificate Signing Request (CSR) is a file that contains information about an entity (e.g., a person, organization, or server) requesting a digital certificate. It is typically used to apply for an SSL/TLS certificate from a Certificate Authority (CA).

Key Details:
A CSR includes:
The entity's public key.
Information like the domain name, organization name, and location.
It is digitally signed using the entity's private key to prove ownership of the public key.
The CA uses the CSR to generate and issue a signed certificate.
In short, a CSR is the first step in obtaining a digital certificate for secure
communication.
