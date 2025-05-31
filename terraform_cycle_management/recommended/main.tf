
resource "random_string" "this" {
  for_each = var.students
  length   = 6
  special  = false
}

locals {
  dob_rfc3339   = { for k, s in var.students : k => "${s.dob}T00:00:00Z" }
  life_end_date = { for k, s in var.students : k => timeadd(local.dob_rfc3339[k], "525600h") }
}

output "students_summary" {
  value = {
    for k, s in var.students :
    k => {
      unique_id     = "${s.first_name}-${random_string.this[k].result}"
      date_of_birth = s.dob
      date_of_death = local.life_end_date[k]
    }
  }
}

