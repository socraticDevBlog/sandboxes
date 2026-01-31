# post-quantum backup encryption tool

## local install

```bash
chmod +x install.sh

./install.sh
```

## encrypt your files

1. edit config.yaml - "include_paths" section
2. run `python backup_tool.py -c config.yaml`
3. enter a password when prompted

## decrypt encrypted files

1. run `python decrypt_backup.py <path_to_file>`
2. enter the password when prompted
