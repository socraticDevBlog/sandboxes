

resource "random_string" "this" {
  length  = 3
  special = false
}

variable "prefix" {
  type    = string
  default = "none"
}

output "random_output" {
  value = "${var.prefix}-${random_string.this.result}"
}
