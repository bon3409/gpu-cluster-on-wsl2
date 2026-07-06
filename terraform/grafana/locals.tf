locals {
  rule_group = {
    dcgm = jsondecode(file("${path.cwd}/rules/dcgm.json"))
  }

  contact_points = {
    default = {
      name  = "Default email"
      email = ["developer@notify.com"]
    }
    warning = {
      name  = "Warning email"
      email = ["warning@notify.com"]
    }
    critical = {
      name  = "Critical email"
      email = ["critical@notify.com"]
    }
  }
}