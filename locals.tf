locals {
  variables = {
    default = local.dev
    dev     = local.dev
    prd     = local.prd
  }

  variable = local.variables[var.ENV]
}

variable "ENV" {}