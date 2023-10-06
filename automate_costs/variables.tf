# Here are the variables
variable "bucket_name" {
  type = string
  description = "The name of the s3 bucket"
  default = "cms-batcave-cost-data-batcave-test"
}

variable "object_key" {
  type = string
  description ="the object key of what is to be updated"
  default = "bat-dev/batcave-dev-daily-costs/batcave-dev-costs-QuickSightManifestAll.json"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = "arn:aws:iam::373346310182:policy/cms-cloud-admin/developer-boundary-policy"
}

variable "iam_path" {}
variable "permissions_boundary" {}
variable "lambda_name" {}
variable "aws_region" {}
variable "environment" {}
variable "project" {}
variable "event_schedule_cron" {}
variable "log_retention" {}
variable "lambda_timeout" {}
