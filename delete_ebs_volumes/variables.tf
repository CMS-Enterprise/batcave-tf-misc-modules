variable "iam_path" {}
variable "permissions_boundary" {}
variable "lambda_name" {}
variable "aws_region" {}
variable "environment" {}
variable "project" {}
variable "event_schedule_cron" {}
variable "log_retention" {}
variable "lambda_timeout" {}
variable "vpc_id" {
  type        = string
  description = "The id of the VPC this lambda should execute within."
}
variable "vpc_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids where the lambda will execute"
}
