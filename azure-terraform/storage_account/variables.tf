variable "name" {
  description = "name for the storage account"
  type        = string
}

variable "location" {
  description = "resource location in Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "resource group name"
  type        = string
}

variable "access_tier" {
  description = "type of storage for performance and cost"
  type        = string
}

variable "whitelisted_ips" {
  description = "IP addresses that can access this bucket"
  type        = set(string)
}

variable "tags" {
  description = "metadata to explain what the resources are"
  type        = map(any)
  default = {
  }
}

variable "container_names" {
  description = "names of the containers inside a bucket"
  type        = set(string)
}
