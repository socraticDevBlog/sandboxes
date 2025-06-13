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
