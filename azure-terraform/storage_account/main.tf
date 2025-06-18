resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  access_tier              = var.access_tier
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = false
  }

  tags = var.tags
}

resource "azurerm_storage_account_network_rules" "whitelist" {
  storage_account_id = azurerm_storage_account.this.id

  default_action = "Deny"
  ip_rules       = var.whitelisted_ips
  bypass         = ["AzureServices"]
}

resource "azurerm_storage_container" "this" {
  for_each = var.container_names

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
