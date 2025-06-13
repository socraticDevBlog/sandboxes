## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.12.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.33.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.33.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/public_ip) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/resource_group) | resource |
| [azurerm_ssh_public_key.dusty_mainframe_key](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/ssh_public_key) | resource |
| [azurerm_storage_account.backups](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.whitelist](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.backups](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/storage_container) | resource |
| [azurerm_subnet.vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vm](https://registry.terraform.io/providers/hashicorp/azurerm/4.33.0/docs/resources/virtual_network) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_public_ssh_key"></a> [azure\_public\_ssh\_key](#input\_azure\_public\_ssh\_key) | n/a | `string` | n/a | yes |
| <a name="input_backup_containers"></a> [backup\_containers](#input\_backup\_containers) | names of containers dedicated to backup storage accounts | `set(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | blob storage account name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Where in the world are my resources provisionned | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Subscription's resource group to group all created resources | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription (Account ID) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | metadata to explain what the resources are | `map(any)` | `{}` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | name of the vm | `string` | n/a | yes |
| <a name="input_vm_os_disk_name"></a> [vm\_os\_disk\_name](#input\_vm\_os\_disk\_name) | unique name for the VM operating system disk | `string` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | n/a | `string` | n/a | yes |
| <a name="input_vm_username"></a> [vm\_username](#input\_vm\_username) | n/a | `string` | n/a | yes |
| <a name="input_whitelisted_ips"></a> [whitelisted\_ips](#input\_whitelisted\_ips) | resources can only be accessed by machines located at these IP addresses | `set(string)` | `[]` | no |

## Outputs

No outputs.
