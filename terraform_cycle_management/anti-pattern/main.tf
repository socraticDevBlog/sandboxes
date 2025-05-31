module "random" {
  for_each = var.students
  source   = "./module_random"
  prefix   = each.value.first_name
}

module "end_of_life" {
  for_each = var.students
  source   = "./module_life_expectancy"
  dob      = each.value.dob

  depends_on = [module.random]
}

output "students_summary" {
  value = {
    for k, s in var.students :
    k => {
      unique_id     = "${module.random[k].random_output}"
      date_of_birth = s.dob
      date_of_death = module.end_of_life[k].life_end_date
    }
  }
}
