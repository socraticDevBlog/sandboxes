# Ansible Playbook for Debian 12 Maintenance

This project provides an Ansible playbook to maintain a Debian 12 virtual machine. It includes roles and tasks to automate common maintenance activities.

## Project Structure

```
ansible-debian12-maintenance
├── playbook.yml          # Main Ansible playbook
├── inventory             # Inventory of hosts
├── group_vars            # Variables for all hosts
│   └── all.yml          # Common variables
├── roles                 # Roles for organizing tasks
│   └── common            # Common role for maintenance tasks
│       ├── tasks
│       │   └── main.yml  # Main tasks for the common role
│       └── handlers
│           └── main.yml  # Handlers for the common role
└── README.md             # Project documentation
```

## Getting Started

### Prerequisites

- Ansible installed on your control machine.
- Access to the Debian 12 VM with SSH.

### Inventory Setup

Edit the `inventory` file at the project root to include the IP addresses or hostnames of your Debian 12 VM.

### Running the Playbook

To execute the playbook, run the following command from the project root:

```sh
ansible-playbook ansible-debian12-maintenance/playbook.yml
```

> **Note:** Make sure to run this command from the project root (where `ansible.cfg` and `inventory` are located).

### Customizing Variables

You can customize variables for all hosts in the `group_vars/all.yml` file. This can include configuration settings, user credentials, and other parameters.

### Role Tasks

The main tasks for the common role are defined in `roles/common/tasks/main.yml`. You can modify this file to add or change tasks as needed.

### Handlers

Handlers that can be triggered by tasks are defined in `roles/common/handlers/main.yml`. Use handlers for actions that should only occur when notified by a task, such as restarting services.

### MOTD Customization

Edit `motd.ascii` to change the login banner displayed to users.

### Default Directories

The playbook ensures the following directories exist in the user's home: `git`, `code`, `docs`, `temp`.

## Contributing

Feel free to submit issues or pull requests to improve this playbook.