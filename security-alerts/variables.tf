# variable "slack_webhook_secret" {
#   type        = string
#   description = "Slack webhook url"
# }

variable "iam_role_path" {
  type    = string
  default = "/delegatedadmin/developer/"
}

variable "step_function_name" {
  type    = string
  default = "sechub_state_machine"
}

variable "account_name" {
  type = string
}

variable "slack_channel_id" {
  type    = string
  default = "C036GQ3E9D1"
}
