variable "subscription_id" {
  description = "Azure Subscription (Account ID)"
  type        = string
}

variable "resource_group_name" {
  description = "Subscription's resource group to group all created resources"
  type        = string
}

variable "region" {
  description = "Where in the world are my resources provisionned"
  type        = string
}

variable "name" {
  description = "blob storage account name"
  type        = string
}

variable "tags" {
  description = "metadata to explain what the resources are"
  type        = map(any)
  default = {
  }
}

variable "whitelisted_ips" {
  description = "resources can only be accessed by machines located at these IP addresses"
  type        = set(string)
  default     = []
}

variable "hot_containers" {
  description = "names of containers dedicated to hot storage accounts"
  type        = set(string)
  default     = []
}

variable "backup_containers" {
  description = "names of containers dedicated to backup storage accounts"
  type        = set(string)
  default     = []
}

variable "vm_name" {
  description = "name of the vm"
  type        = string
}

variable "azure_public_ssh_key" {
  type = string
}

variable "vm_username" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "vm_os_disk_name" {
  description = "unique name for the VM operating system disk"
  type        = string
}