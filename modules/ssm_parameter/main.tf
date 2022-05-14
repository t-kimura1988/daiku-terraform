variable "string_parameters" {}
variable "secure_parameters" {}
variable "env" {}

resource "aws_ssm_parameter" "string" {
  for_each = var.string_parameters
  name     = "/ENV/${var.env}/${each.key}"
  type     = "String"
  value    = each.value
}

resource "aws_ssm_parameter" "secure" {
  for_each = var.secure_parameters
  name     = "/ENV/${var.env}/${each.key}"
  type     = "SecureString"
  value    = each.value

  lifecycle {
    ignore_changes = [value]
  }
}