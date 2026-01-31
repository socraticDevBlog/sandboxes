#!/usr/bin/env python3
"""
Decryption tool for backups created with backup_tool.py
Supports both Post-Quantum (Kyber) and AES-256-GCM encrypted files
"""

import os
import sys
import argparse
import logging
from pathlib import Path

try:
    import oqs
except ImportError:
    oqs = None

from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.backends import default_backend
from cryptography.exceptions import InvalidTag

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class BackupDecryptor:
    """Decrypt backups created with backup_tool.py"""
    
    def __init__(self, password: str):
        self.password = password
    
    def detect_encryption_type(self, file_path: str) -> str:
        """Detect encryption type from file header"""
        with open(file_path, 'rb') as f:
            header = f.read(9)
        
        if header == b'AES256GCM':
            return 'aes'
        elif header[:8] == b'PQBACKUP':
            return 'pq'
        else:
            return 'unknown'
    
    def decrypt_aes_file(self, input_path: str, output_path: str):
        """Decrypt AES-256-GCM encrypted file"""
        from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
        from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.backends import default_backend
        
        with open(input_path, 'rb') as f:
            # Read header
            header = f.read(9)
            if header != b'AES256GCM':
                raise ValueError("Not an AES-256-GCM encrypted file")
            
            # Read encryption metadata
            salt = f.read(16)
            iv = f.read(16)
            tag = f.read(16)
            ciphertext = f.read()
        
        # Derive key
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
            backend=default_backend()
        )
        key = kdf.derive(self.password.encode())
        
        # Decrypt
        cipher = Cipher(
            algorithms.AES(key),
            modes.GCM(iv, tag),
            backend=default_backend()
        )
        decryptor = cipher.decryptor()
        
        plaintext = decryptor.update(ciphertext) + decryptor.finalize()
        
        # Write decrypted file
        with open(output_path, 'wb') as f:
            f.write(plaintext)
        
        logger.info(f"Decrypted with AES-256-GCM: {output_path}")
    
    def decrypt_pq_file(self, input_path: str, output_path: str):
        """Decrypt post-quantum encrypted file.

        Supports two PQ formats kept in the repo:
        - "PQBACKUP" (password-based KDF + AES-GCM)
        - KEM-based hybrid (algorithm name, KEM ciphertext, wrapped private key, AES-GCM payload)
        """
        # Open file and peek header to decide format
        with open(input_path, 'rb') as f:
            header = f.read(8)

        if header == b'PQBACKUP':
            # Existing password-based PQBACKUP format

            with open(input_path, 'rb') as f:
                # Read header
                magic = f.read(8)
                # Read KDF type
                kdf_type_len = int.from_bytes(f.read(1), 'big')
                kdf_type = f.read(kdf_type_len)
                # Read encryption metadata
                salt = f.read(32)
                iv = f.read(16)
                tag = f.read(16)
                ciphertext = f.read()

            # Derive key based on KDF type
            if kdf_type == b'ARGON2ID':
                try:
                    import argon2
                    from argon2.low_level import hash_secret_raw, Type

                    key = hash_secret_raw(
                        secret=self.password.encode(),
                        salt=salt,
                        time_cost=3,
                        memory_cost=65536,
                        parallelism=4,
                        hash_len=32,
                        type=Type.ID
                    )
                    logger.info("Using Argon2id KDF")
                except ImportError:
                    raise ImportError("argon2-cffi required to decrypt this file. Install: pip install argon2-cffi")

            elif kdf_type == b'PBKDF2SHA512':
                kdf = PBKDF2HMAC(
                    algorithm=hashes.SHA512(),
                    length=32,
                    salt=salt,
                    iterations=500000,
                    backend=default_backend()
                )
                key = kdf.derive(self.password.encode())
                logger.info("Using PBKDF2-HMAC-SHA512 KDF")
            else:
                raise ValueError(f"Unknown KDF type: {kdf_type}")

            # Decrypt
            cipher = Cipher(
                algorithms.AES(key),
                modes.GCM(iv, tag),
                backend=default_backend()
            )
            decryptor = cipher.decryptor()

            plaintext = decryptor.update(ciphertext) + decryptor.finalize()

            # Write decrypted file
            with open(output_path, 'wb') as f:
                f.write(plaintext)

            logger.info(f"Decrypted with AES-256-GCM + {kdf_type.decode()}: {output_path}")

        else:
            # Assume KEM-based hybrid format we've adopted

            with open(input_path, 'rb') as f:
                # Read algorithm name
                algo_len = int.from_bytes(f.read(2), 'big')
                algo_name = f.read(algo_len).decode()

                # Read KEM ciphertext
                kem_ct_len = int.from_bytes(f.read(4), 'big')
                kem_ciphertext = f.read(kem_ct_len)

                # Read wrapped private key
                wrapped_len = int.from_bytes(f.read(4), 'big')
                wrap_salt = f.read(16)
                wrap_iv = f.read(16)
                wrap_tag = f.read(16)
                wrapped_private_key = f.read(wrapped_len)

                # Read encryption metadata
                salt = f.read(16)
                iv = f.read(16)
                tag = f.read(16)
                ciphertext = f.read()

            # Unwrap private key using password
            try:
                wrap_kdf = PBKDF2HMAC(
                    algorithm=hashes.SHA256(),
                    length=32,
                    salt=wrap_salt,
                    iterations=100000,
                    backend=default_backend()
                )
                wrap_key = wrap_kdf.derive(self.password.encode())

                wrap_cipher = Cipher(
                    algorithms.AES(wrap_key),
                    modes.GCM(wrap_iv, wrap_tag),
                    backend=default_backend()
                )
                wrap_decryptor = wrap_cipher.decryptor()
                private_key = wrap_decryptor.update(wrapped_private_key) + wrap_decryptor.finalize()
            except InvalidTag:
                raise ValueError("Incorrect password or corrupted wrapped private key")

            # Initialize KEM with private key and decapsulate
            kem = oqs.KeyEncapsulation(algo_name, secret_key=private_key)
            shared_secret = kem.decap_secret(kem_ciphertext)

            # Derive file encryption key
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt,
                iterations=100000,
                backend=default_backend()
            )
            key = kdf.derive(shared_secret + self.password.encode())

            # Decrypt file
            cipher = Cipher(
                algorithms.AES(key),
                modes.GCM(iv, tag),
                backend=default_backend()
            )
            decryptor = cipher.decryptor()
            try:
                plaintext = decryptor.update(ciphertext) + decryptor.finalize()
            except InvalidTag:
                raise ValueError("Decryption failed: authentication tag mismatch (wrong password or corrupted file)")

            # Write decrypted file
            with open(output_path, 'wb') as f:
                f.write(plaintext)

            logger.info(f"Decrypted with post-quantum hybrid scheme: {output_path}")
    
    def decrypt_file(self, input_path: str, output_path: str = None):
        """Decrypt a backup file (auto-detect encryption type)"""
        if not os.path.exists(input_path):
            raise FileNotFoundError(f"Input file not found: {input_path}")
        
        if output_path is None:
            # Remove .encrypted extension or add .decrypted
            if input_path.endswith('.encrypted'):
                output_path = input_path[:-10]  # Remove .encrypted
            else:
                output_path = input_path + '.decrypted'
        
        encryption_type = self.detect_encryption_type(input_path)
        logger.info(f"Detected encryption type: {encryption_type.upper()}")
        
        if encryption_type == 'aes':
            self.decrypt_aes_file(input_path, output_path)
        elif encryption_type == 'pq':
            self.decrypt_pq_file(input_path, output_path)
        else:
            raise ValueError(f"Unknown encryption type. File may be corrupted or use an unsupported format.")
        
        return output_path


def main():
    parser = argparse.ArgumentParser(
        description='Decrypt backups created with backup_tool.py'
    )
    parser.add_argument('input_file', help='Encrypted backup file to decrypt')
    parser.add_argument('-o', '--output', help='Output file path (default: remove .encrypted extension)')
    parser.add_argument('-p', '--password', help='Decryption password (or use DECRYPTION_PASSWORD env var)')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose logging')
    
    args = parser.parse_args()
    
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    # Get password
    password = args.password or os.getenv('DECRYPTION_PASSWORD')
    if not password:
        # Prompt for password
        import getpass
        password = getpass.getpass('Enter decryption password: ')
    
    try:
        decryptor = BackupDecryptor(password)
        output_file = decryptor.decrypt_file(args.input_file, args.output)
        logger.info(f"Successfully decrypted to: {output_file}")
        logger.info(f"Extract with: unzip {output_file}")

        # Attempt to automatically extract the decrypted zip file in-place
        try:
            if output_file.endswith('.zip') and os.path.exists(output_file):
                import zipfile

                dest_dir = os.path.dirname(output_file) or '.'
                abs_dest = os.path.abspath(dest_dir)

                # Zip-slip protection: ensure every member extracts inside dest_dir
                with zipfile.ZipFile(output_file, 'r') as zf:
                    for member in zf.namelist():
                        member_path = os.path.abspath(os.path.join(abs_dest, member))
                        if not (member_path == abs_dest or member_path.startswith(abs_dest + os.sep)):
                            logger.error(f"Zip contains unsafe path, aborting extraction: {member}")
                            raise Exception("Unsafe zip entry detected")
                    zf.extractall(dest_dir)

                logger.info(f"Automatically extracted zip to: {dest_dir}")
            else:
                logger.debug("Output is not a zip archive; skipping automatic extraction")
        except Exception as e:
            logger.error(f"Automatic extraction failed: {e}")
    except Exception as e:
        logger.error(f"Decryption failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
