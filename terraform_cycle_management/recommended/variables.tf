variable "students" {
  type = map(object({
    first_name = string
    last_name  = string
    dob        = string
  }))
  default = {
    "123-45-6789" = {
      first_name = "Alice"
      last_name  = "Martin"
      dob        = "1990-01-01"
    }
    "987-65-4321" = {
      first_name = "Bob"
      last_name  = "Durand"
      dob        = "1992-05-12"
    }
    "555-66-7777" = {
      first_name = "Claire"
      last_name  = "Dubois"
      dob        = "1988-11-23"
    }
  }
}