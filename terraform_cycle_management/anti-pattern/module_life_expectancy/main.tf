variable "dob" {
  description = "date of birth"
  type        = string
}


locals {
  dob_rfc3339   = "${var.dob}T00:00:00Z"
  life_end_date = timeadd(local.dob_rfc3339, "525600h") # 60 ans * 8760h/an = 525600h
}

output "life_end_date" {
  value = local.life_end_date
}