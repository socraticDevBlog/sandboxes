# Azure Terraform Storage Account Provisioning

This project provides a best-practice example for provisioning Azure resources—specifically a Storage Account—using Terraform. It demonstrates secure backend state management, tagging, network rules, and includes clear documentation generation using [terraform-docs](https://terraform-docs.io/).

## Purpose

- Provision an Azure Storage Account with secure, private access.
- Enforce best practices for tagging and resource configuration.
- Use a remote backend (Azure Storage Account) for Terraform state management.
- Generate and maintain up-to-date documentation with terraform-docs.

---

## Project Structure

```
azure-terraform/
├── backend.tf.template   # Template for backend configuration
├── backend.tf           # Actual backend config (not commited)
├── docs.md              # Generated documentation (terraform-docs)
├── main.tf              # Main Terraform configuration
├── private.tfvars.gpg   # encrypted Private variable values 
├── providers.tf         # Provider and version pinning
├── variables.tf         # Variable definitions
└── README.md            # This documentation
```

---

## Backend State Management

Terraform state is stored remotely in an Azure Storage Account for security and collaboration. The backend configuration is templated in `backend.tf.template`:

```
terraform {
  backend "azurerm" {
    resource_group_name  = ""                        # Replace with your resource group name
    storage_account_name = ""                        # Replace with your storage account name
    container_name       = "sandbox-azure-terraform" # Replace with your container name
    key                  = "terraform.tfstate"       # Name of the state file
  }
}
```

### How to Use the Backend Template

1. **Copy the template:**
   ```sh
   cp backend.tf.template backend.tf
   ```
2. **Edit `backend.tf`:** Fill in your actual Azure resource group, storage account, and container names.
3. **Initialize Terraform:**
   ```sh
   terraform init
   ```

---

## Provider and Version Pinning

Provider versions and the Terraform version are pinned in `providers.tf` for reproducibility and stability. Example:

```
terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
```

---

## Storage Account Configuration

- **Private Access:** The storage account is configured to be private, with network rules allowing only whitelisted IPs.
- **Blob Versioning:** Enabled for data protection.
- **Tags:** Uses the `merge` function to combine default and custom tags.
- **Best-Practice Tags:**
  - `environment`, `owner`, `project`, `cost_center`, `created_by`, etc.

---

## Variables and Sensitive Data

- All variables are defined in `variables.tf`.
- Sensitive values (like resource names, whitelisted IPs) are set in
  `private.tfvars.gpg` and decrypted at command-time using [GNU Privacy
  Guard](https://www.gnupg.org/) cli tool

- Example usage:
  ```sh
  terraform plan -var-file=<(gpg -d private.tfvars.gpg)
  ```

---

## Documentation Generation with terraform-docs

[terraform-docs](https://terraform-docs.io/) automatically generates documentation from your Terraform modules.

### Installation

- **macOS:**
  ```sh
  brew install terraform-docs
  ```
- **Other OS:** See [terraform-docs installation guide](https://terraform-docs.io/user-guide/installation/)

### Usage

From the `azure-terraform` directory:

```sh
terraform-docs markdown table . |> docs.md
```

This will generate a markdown table of inputs, outputs, and resources in `docs.md`.

---

## Quickstart

1. **Copy and edit backend config:**
   ```sh
   cp backend.tf.template backend.tf
   # Edit backend.tf with your Azure details
   ```
2. **Initialize Terraform:**
   ```sh
   terraform init
   ```
3. **Set your variables:**
   - Edit `private.tfvars` with your values.
4. **Plan and apply:**
   ```sh
   terraform plan -var-file="private.tfvars"
   terraform apply -var-file="private.tfvars"
   ```
5. **Generate documentation:**
   ```sh
   terraform-docs markdown table . > docs.md
   ```

---

## Additional Notes

- **Security:** Never commit `private.tfvars` or credentials to version control.
- **State Locking:** Azure Storage Account backend provides state locking and consistency.
- **Network Rules:** Only whitelisted IPs can access the storage account.
- **Blob Versioning:** Enabled for data protection and recovery.

---

## References

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [terraform-docs](https://terraform-docs.io/)
- [Azure Storage Account Docs](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)

---

## License

MIT License
