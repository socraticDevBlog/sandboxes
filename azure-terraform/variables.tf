variable "subscription_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(any)
  default = {

  }
}

variable "whitelisted_ips" {
  type    = set(string)
  default = []
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
  type = string
}