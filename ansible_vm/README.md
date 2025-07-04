![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)

# Ansible Debian 12 VM Automation

This repository provides two main Ansible playbooks for managing and configuring your Debian 12 virtual machines:

## 1. System Maintenance Playbook

**Location:** `ansible-debian12-maintenance/playbook.yml`

This playbook is designed for general system maintenance and hardening. It:
- Updates and upgrades system packages
- Installs essential packages (configurable in `group_vars/all.yml`)
- Cleans up unused packages
- Optionally reboots the system if updates were applied
- Sets the system timezone and hostname
- Configures a custom ASCII MOTD (editable in `motd.ascii`)
- Ensures default directories (`git`, `code`, `docs`, `temp`) exist in the user's home directory

**Usage:**
```sh
ansible-playbook ansible-debian12-maintenance/playbook.yml
```

## 2. Developer/Leisure Environment Playbook

**Location:** `comfy_stuff/playbook.yml`

This playbook sets up a comfortable coding and leisure environment. It:
- Installs tools like weechat, zsh, and powerline fonts
- Sets up oh-my-zsh and the powerlevel10k theme
- Installs and configures Vim with vim-plug, sensible plugins, and ALE for linting/formatting
- Installs Python and shell linters/formatters (flake8, mypy, black, isort, shellcheck, shfmt)
- Installs pipenv and pyenv for Python environment management

**Usage:**
```sh
ansible-playbook comfy_stuff/playbook.yml
```

## Inventory Management
- The real `inventory` file should be kept private (see `.gitignore`).
- An anonymized template is provided as `inventory.template` in each playbook directory.

## Customization
- Edit `group_vars/all.yml` to change system-wide variables (packages, hostname, etc).
- Edit `motd.ascii` to customize the login banner.
- Edit the playbooks or their variables to add/remove packages and tools as needed.

## Project Structure
- `ansible-debian12-maintenance/` — System maintenance playbook and roles
- `comfy_stuff/` — Developer/leisure environment playbook
- `inventory` — Your private inventory file (not committed)
- `inventory.template` — Example inventory file for sharing

## ansible-vault

create a password-protected vault (if none exist)
```bash
ansible-vault create vault.yml
```

save your vault password in KeepasXC new entry: "ansible vault"

to view the secret

```bash
ansible-vault view vault.yml
```

### required for postgresql_provision

```bash
ansible-playbook postgresql_provision/playbook.yml --ask-vault-password
```
