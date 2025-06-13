resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.region
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

resource "azurerm_storage_account" "backups" {
  name                     = "sa${var.name}${random_pet.this.id}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  blob_properties {
    versioning_enabled = false
  }

  tags = merge(var.tags, { purpose = "backups" })
}

resource "azurerm_storage_account_network_rules" "whitelist" {
  storage_account_id = azurerm_storage_account.backups.id

  default_action = "Deny"
  ip_rules       = var.whitelisted_ips
}
