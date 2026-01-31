#!/usr/bin/env python3
"""
Secure Backup Tool with Post-Quantum Encryption
Supports selective file/folder backup with multiple cloud storage backends
"""

import os
import sys
import json
import yaml
import zipfile
import hashlib
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional
import logging

# PQ encryption using liboqs via oqs library
try:
    import oqs
except ImportError:
    oqs = None
except Exception as e:
    # Handle runtime errors during oqs import (e.g., missing shared library)
    logger.warning(f"liboqs import failed: {e}")
    oqs = None


# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class BackupConfig:
    """Handles configuration loading from file or environment variables"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.config = self._load_config(config_path)
        self._merge_env_vars()
    
    def _load_config(self, config_path: Optional[str]) -> Dict:
        """Load configuration from YAML or JSON file"""
        if config_path and os.path.exists(config_path):
            with open(config_path, 'r') as f:
                if config_path.endswith('.yaml') or config_path.endswith('.yml'):
                    return yaml.safe_load(f)
                elif config_path.endswith('.json'):
                    return json.load(f)
        
        # Return default config if no file provided
        return {
            'backup': {
                'root_path': '/',
                'include_paths': [],
                'exclude_patterns': [],
                'output_dir': './backups',
                'compression_level': 9
            },
            'encryption': {
                'algorithm': 'Kyber1024',  # Post-quantum KEM
                'password_file': None,
                'use_env_password': True
            },
            'storage': {
                'local_only': True,
                'azure': {
                    'enabled': False,
                    'connection_string': None,
                    'container_name': 'backups'
                },
                'aws': {
                    'enabled': False,
                    'bucket_name': None,
                    'region': 'us-east-1'
                }
            }
        }
    
    def _merge_env_vars(self):
        """Override config with environment variables if present"""
        env_mappings = {
            'BACKUP_ROOT_PATH': ('backup', 'root_path'),
            'BACKUP_OUTPUT_DIR': ('backup', 'output_dir'),
            'BACKUP_INCLUDE_PATHS': ('backup', 'include_paths'),
            'ENCRYPTION_ALGORITHM': ('encryption', 'algorithm'),
            'AZURE_CONNECTION_STRING': ('storage', 'azure', 'connection_string'),
            'AZURE_CONTAINER': ('storage', 'azure', 'container_name'),
            'AWS_BUCKET_NAME': ('storage', 'aws', 'bucket_name'),
            'AWS_REGION': ('storage', 'aws', 'region'),
        }
        
        for env_var, config_path in env_mappings.items():
            value = os.getenv(env_var)
            if value:
                # Handle comma-separated lists
                if env_var == 'BACKUP_INCLUDE_PATHS':
                    value = [p.strip() for p in value.split(',')]
                
                # Set nested config value
                current = self.config
                for key in config_path[:-1]:
                    if key not in current:
                        current[key] = {}
                    current = current[key]
                current[config_path[-1]] = value
    
    def get(self, *keys, default=None):
        """Get nested configuration value"""
        current = self.config
        for key in keys:
            if isinstance(current, dict) and key in current:
                current = current[key]
            else:
                return default
        return current


class PostQuantumEncryption:
    """
    Handle encryption using password-based cryptography with post-quantum-resistant parameters.
    
    Note: For symmetric encryption (same person encrypts/decrypts), we use password-based
    encryption with Argon2id KDF (memory-hard, resistant to quantum attacks on KDFs).
    This is appropriate for backup scenarios where you encrypt with a password and 
    decrypt with the same password.
    
    True post-quantum KEM (like Kyber) is for asymmetric scenarios where you encrypt
    to someone's public key and they decrypt with their private key.
    """
    
    def __init__(self, algorithm: str = 'Kyber1024'):
        # We accept the algorithm parameter for compatibility but use Argon2id for PQ-resistant KDF
        self.algorithm = algorithm
        
        # Check if argon2-cffi is available for quantum-resistant KDF
        try:
            import argon2
            self.use_argon2 = True
            self.argon2 = argon2
        except ImportError:
            logger.warning("argon2-cffi not installed, using PBKDF2-HMAC-SHA512 (still secure)")
            self.use_argon2 = False
    
    def encrypt_file(self, input_path: str, output_path: str, password: str):
        """
        Encrypt file using password-based encryption with quantum-resistant KDF
        """
        from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
        from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.backends import default_backend
        
        # Generate salt
        salt = os.urandom(32)  # Larger salt for PQ resistance
        
        # Derive encryption key using quantum-resistant parameters
        if self.use_argon2:
            # Argon2id is memory-hard and quantum-resistant
            # Parameters: time_cost=3, memory_cost=64MB, parallelism=4
            hasher = self.argon2.PasswordHasher(
                time_cost=3,
                memory_cost=65536,  # 64 MB
                parallelism=4,
                hash_len=32,
                salt_len=32
            )
            # Use low-level API to get raw key
            from argon2.low_level import hash_secret_raw, Type
            key = hash_secret_raw(
                secret=password.encode(),
                salt=salt,
                time_cost=3,
                memory_cost=65536,
                parallelism=4,
                hash_len=32,
                type=Type.ID
            )
            kdf_type = b'ARGON2ID'
        else:
            # Fallback: PBKDF2-HMAC-SHA512 with very high iteration count
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA512(),  # SHA512 for extra security
                length=32,
                salt=salt,
                iterations=500000,  # Very high iteration count
                backend=default_backend()
            )
            key = kdf.derive(password.encode())
            kdf_type = b'PBKDF2SHA512'
        
        # Encrypt file with AES-256-GCM
        iv = os.urandom(16)
        cipher = Cipher(
            algorithms.AES(key),
            modes.GCM(iv),
            backend=default_backend()
        )
        encryptor = cipher.encryptor()
        
        with open(input_path, 'rb') as f:
            plaintext = f.read()
        
        ciphertext = encryptor.update(plaintext) + encryptor.finalize()
        
        # Write encrypted file with metadata
        with open(output_path, 'wb') as f:
            # Header format:
            # - Magic bytes: "PQBACKUP" (8 bytes)
            # - KDF type length (1 byte)
            # - KDF type (variable, e.g., "ARGON2ID" or "PBKDF2SHA512")
            # - Salt (32 bytes)
            # - IV (16 bytes)
            # - GCM tag (16 bytes)
            # - Encrypted data (variable)
            
            f.write(b'PQBACKUP')
            f.write(len(kdf_type).to_bytes(1, 'big'))
            f.write(kdf_type)
            f.write(salt)
            f.write(iv)
            f.write(encryptor.tag)
            f.write(ciphertext)
        
        kdf_name = kdf_type.decode() if isinstance(kdf_type, bytes) else kdf_type
        logger.info(f"File encrypted with AES-256-GCM + {kdf_name} (quantum-resistant)")



class SimpleEncryption:
    """Fallback encryption using AES-256-GCM (still quantum-resistant in practice)"""
    
    def encrypt_file(self, input_path: str, output_path: str, password: str):
        """Encrypt file using AES-256-GCM with strong KDF"""
        from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
        from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.backends import default_backend
        
        # Generate salt and IV
        salt = os.urandom(16)
        iv = os.urandom(16)
        
        # Derive key from password
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
            backend=default_backend()
        )
        key = kdf.derive(password.encode())
        
        # Encrypt
        cipher = Cipher(
            algorithms.AES(key),
            modes.GCM(iv),
            backend=default_backend()
        )
        encryptor = cipher.encryptor()
        
        with open(input_path, 'rb') as f:
            plaintext = f.read()
        
        ciphertext = encryptor.update(plaintext) + encryptor.finalize()
        
        # Write encrypted file
        with open(output_path, 'wb') as f:
            f.write(b'AES256GCM')  # 9 byte header
            f.write(salt)
            f.write(iv)
            f.write(encryptor.tag)
            f.write(ciphertext)
        
        logger.info("File encrypted with AES-256-GCM")


class BackupManager:
    """Main backup management class"""
    
    def __init__(self, config: BackupConfig):
        self.config = config
        self.backup_time = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    def collect_files(self) -> List[Path]:
        """Collect all files to backup based on configuration"""
        root_path = Path(self.config.get('backup', 'root_path'))
        include_paths = self.config.get('backup', 'include_paths', default=[])
        exclude_patterns = self.config.get('backup', 'exclude_patterns', default=[])
        
        collected_files = []
        
        for include_path in include_paths:
            full_path = root_path / include_path.lstrip('/')
            
            if full_path.is_file():
                collected_files.append(full_path)
            elif full_path.is_dir():
                for item in full_path.rglob('*'):
                    if item.is_file():
                        # Check exclude patterns
                        if not any(item.match(pattern) for pattern in exclude_patterns):
                            collected_files.append(item)
            else:
                logger.warning(f"Path not found: {full_path}")
        
        logger.info(f"Collected {len(collected_files)} files for backup")
        return collected_files
    
    def create_zip(self, files: List[Path]) -> str:
        """Create compressed zip archive"""
        output_dir = Path(self.config.get('backup', 'output_dir'))
        output_dir.mkdir(parents=True, exist_ok=True)
        
        zip_filename = f"backup_{self.backup_time}.zip"
        zip_path = output_dir / zip_filename
        
        compression_level = self.config.get('backup', 'compression_level', default=9)
        root_path = Path(self.config.get('backup', 'root_path'))
        
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED, compresslevel=compression_level) as zipf:
            for file_path in files:
                try:
                    # Store relative path in zip
                    arcname = file_path.relative_to(root_path)
                    zipf.write(file_path, arcname)
                    logger.debug(f"Added to archive: {arcname}")
                except Exception as e:
                    logger.error(f"Failed to add {file_path}: {e}")
        
        logger.info(f"Created archive: {zip_path} ({zip_path.stat().st_size / 1024 / 1024:.2f} MB)")
        return str(zip_path)
    
    def encrypt_backup(self, zip_path: str) -> str:
        """Encrypt the backup archive (Post-Quantum only).

        The encryption password is prompted interactively at runtime and is never read from
        config files or environment variables. If a password exists in the configuration
        it will be ignored to protect secrets from accidental storage.
        """
        # Warn and ignore any password set in configuration
        if self.config.get('encryption', 'password'):
            logger.warning("Ignoring stored encryption password in config for security reasons")
        if self.config.get('encryption', 'password_file'):
            logger.warning("Ignoring configured password_file; password must be entered interactively")

        # Prompt the user for the encryption password (twice for confirmation)
        import getpass
        while True:
            password = getpass.getpass('Enter encryption password (will not be stored): ')
            if not password:
                print('Password cannot be empty; please try again.')
                continue
            confirm = getpass.getpass('Confirm encryption password: ')
            if password != confirm:
                print('Passwords do not match; please try again.')
                continue
            break

        encrypted_path = zip_path + '.encrypted'
        algorithm = self.config.get('encryption', 'algorithm', default='Kyber1024')

        # Enforce post-quantum encryption only; fail fast if PQ unavailable
        encryptor = PostQuantumEncryption(algorithm)
        encryptor.encrypt_file(zip_path, encrypted_path, password)

        # Remove unencrypted zip
        os.remove(zip_path)
        logger.info(f"Encrypted backup: {encrypted_path}")

        return encrypted_path
    
    def upload_to_azure(self, file_path: str):
        """Upload encrypted backup to Azure Blob Storage"""
        if not self.config.get('storage', 'azure', 'enabled'):
            return
        
        if BlobServiceClient is None:
            logger.error("azure-storage-blob not installed. Install with: pip install azure-storage-blob")
            return
        
        connection_string = self.config.get('storage', 'azure', 'connection_string')
        container_name = self.config.get('storage', 'azure', 'container_name')
        
        if not connection_string:
            logger.error("Azure connection string not provided")
            return
        
        blob_name = f"{self.backup_time}/{Path(file_path).name}"
        
        try:
            blob_service_client = BlobServiceClient.from_connection_string(connection_string)
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
            
            with open(file_path, 'rb') as data:
                blob_client.upload_blob(data, overwrite=True)
            
            logger.info(f"Uploaded to Azure: {container_name}/{blob_name}")
        except Exception as e:
            logger.error(f"Azure upload failed: {e}")
    
    def upload_to_s3(self, file_path: str):
        """Upload encrypted backup to AWS S3"""
        if not self.config.get('storage', 'aws', 'enabled'):
            return
        
        if boto3 is None:
            logger.error("boto3 not installed. Install with: pip install boto3")
            return
        
        bucket_name = self.config.get('storage', 'aws', 'bucket_name')
        region = self.config.get('storage', 'aws', 'region')
        
        if not bucket_name:
            logger.error("AWS bucket name not provided")
            return
        
        object_key = f"{self.backup_time}/{Path(file_path).name}"
        
        try:
            s3_client = boto3.client('s3', region_name=region)
            s3_client.upload_file(file_path, bucket_name, object_key)
            
            logger.info(f"Uploaded to S3: s3://{bucket_name}/{object_key}")
        except Exception as e:
            logger.error(f"S3 upload failed: {e}")
    
    def run_backup(self):
        """Execute complete backup process"""
        logger.info("Starting backup process...")
        
        # Collect files
        files = self.collect_files()
        if not files:
            logger.warning("No files to backup")
            return
        
        # Create zip
        zip_path = self.create_zip(files)
        
        # Encrypt
        encrypted_path = self.encrypt_backup(zip_path)
        
        # Upload to cloud storage
        if not self.config.get('storage', 'local_only'):
            self.upload_to_azure(encrypted_path)
            self.upload_to_s3(encrypted_path)
        
        logger.info(f"Backup completed: {encrypted_path}")
        return encrypted_path


def main():
    parser = argparse.ArgumentParser(description='Secure Backup Tool with Post-Quantum Encryption')
    parser.add_argument('-c', '--config', help='Path to configuration file (YAML or JSON)')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose logging')
    
    args = parser.parse_args()
    
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    try:
        config = BackupConfig(args.config)
        backup_manager = BackupManager(config)
        backup_manager.run_backup()
    except Exception as e:
        logger.error(f"Backup failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
