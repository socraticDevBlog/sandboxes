## Implementation note: user and database creation

Due to a known limitation in Ansible (on Debian/Ubuntu) when using become_user: postgres, the playbook uses shell tasks with `sudo -u postgres` to create the PostgreSQL user and database. This approach is a workaround to avoid Ansible's permission errors when trying to escalate privileges to the `postgres` user for these operations.

This method is safe and reliable, but differs from the usual use of Ansible's native PostgreSQL modules. If a future version of Ansible resolves this bug, you may revert to using the `community.postgresql` modules directly with `become_user: postgres`.
## Accessing your database from your local machine (DBeaver, etc.)

If you want to connect to your PostgreSQL database securely from your local machine, you can use an SSH tunnel with port forwarding. This avoids exposing your database port (5432) to the internet.

**Example command:**

```sh
ssh -L 5432:localhost:5432 <my vps host url>
```

This command will forward your local port 5432 to the remote server's port 5432 via SSH. Leave this terminal open while you use DBeaver.

**In DBeaver:**
  - Host: `localhost`
  - Port: `5432`
  - Database: `<my_database_name>`
  - Username: `<db_username>`
  - Password: `<db_user_password>`

You can now connect as if the database was running locally.

**Tip:** You can also use DBeaver's built-in SSH tunnel feature in the connection settings ("SSH" tab), using the same SSH credentials.
# PostgreSQL Provision Playbook

This playbook provisions a PostgreSQL database on your Debian 12 VPS.

## Features
- Installs PostgreSQL
- Ensures the PostgreSQL service is running and enabled
- Creates a PostgreSQL user (configurable)
- Creates a PostgreSQL database (configurable)

## Usage


1. Edit your root `inventory` file to set your desired database name, user, and password, for example:

   ```ini
   [debian12_vm]
   <my_host_url> ansible_ssh_user=anon pg_user=myuser pg_password=mypassword pg_database=mydb
   ```


2. Install the required Ansible collection on your control machine (not on the server):

   ```sh
   ansible-galaxy collection install community.postgresql
   ```

   This step is only needed once, and never installs anything on your server—only on your local machine where you run Ansible.

3. Run the playbook:

   ```sh
   ansible-playbook playbook.yml
   ```

If you see a warning about "No inventory was parsed", make sure you run this command from the root of your project (where the `ansible.cfg` and `inventory` files are located), or specify the inventory path with `-i ../inventory` if running from another directory.

## Variables
The following variables must be set in your root `inventory` file:

- `pg_user`: The PostgreSQL username to create
- `pg_password`: The password for the PostgreSQL user
- `pg_database`: The name of the database to create

## Inventory
- Use your private `inventory` file (not committed to git).
- An example `inventory.template` can be provided if needed.
