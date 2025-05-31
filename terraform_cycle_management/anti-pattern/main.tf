module "random" {
  for_each = var.students
  source   = "./module_random"
  prefix   = each.value.first_name
}

output "unique_id" {
  value = { for k, mod in module.random : k => mod.random_output }
}

module "end_of_life" {
  for_each = var.students
  source   = "./module_life_expectancy"
  dob      = each.value.dob

  depends_on = [module.random]
}

output "ends_of_life" {
  value = { for k, mod in module.end_of_life : k => mod.life_end_date }
}