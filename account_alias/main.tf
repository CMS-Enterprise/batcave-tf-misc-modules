resource "aws_iam_account_alias" "alias" {
  account_alias = var.alias_name
}

variable "alias_name" {
  type        = string
  description = "This is the alias name that will be set."
  validation {
    condition     = length(var.alias_name) >= 3 && length(var.alias_name) <= 63
    error_message = "Account Alias must have between 3 and 63 characters."
  }
}
