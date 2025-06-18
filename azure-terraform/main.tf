resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.region
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

module "storageaccounts_backups" {
  source = "./storage_account"

  access_tier         = "Cool"
  container_names     = var.backup_containers
  name                = "sa${var.name}${random_pet.this.id}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = merge(var.tags, { purpose = "backups" })
  whitelisted_ips     = var.whitelisted_ips
}

module "storageaccounts_hot" {
  source = "./storage_account"

  access_tier         = "Hot"
  container_names     = var.hot_containers
  name                = "hot${var.name}${random_pet.this.id}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = merge(var.tags, { purpose = "live storage" })
  whitelisted_ips     = var.whitelisted_ips
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                       = upper("${var.vm_name}")
  resource_group_name        = upper(azurerm_resource_group.this.name)
  location                   = azurerm_resource_group.this.location
  size                       = var.vm_size
  admin_username             = var.vm_username
  disk_controller_type       = "SCSI"
  encryption_at_host_enabled = false
  vtpm_enabled               = false
  tags                       = var.tags
  secure_boot_enabled        = false

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  os_disk {
    name                 = var.vm_os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  additional_capabilities {
    hibernation_enabled = false
    ultra_ssd_enabled   = false
  }

  source_image_reference {
    publisher = "debian"
    offer     = "debian-12"
    sku       = "12-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.vm_username
    public_key = azurerm_ssh_public_key.dusty_mainframe_key.public_key
  }

  disable_password_authentication = true

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    # enabled is not supported in azurerm_linux_virtual_machine, always enabled if storage_uri is set or managed boot diagnostics is used
  }
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.vm_name}304"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_public_ip" "vm" {
  name                = "${var.vm_name}-ip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_virtual_network" "vm" {
  name                = "${var.vm_name}-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_name}-nsg"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  dynamic "security_rule" {
    for_each = var.whitelisted_ips

    content {
      name                       = "SSH"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  tags = var.tags
}

resource "azurerm_ssh_public_key" "dusty_mainframe_key" {
  name                = "${var.vm_name}_key"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  public_key          = var.azure_public_ssh_key
  tags                = var.tags
}

resource "azurerm_subnet" "vm" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefixes     = ["10.0.0.0/24"]
}
