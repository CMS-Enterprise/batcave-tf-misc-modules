locals {
  aws_region           = get_env("AWS_DEFAULT_REGION", "us-east-1")
  allowed_account_ids  = "373346310182"
  lambda_name          = "delete_ebs_volumes"
  environment          = "dev"
  directory_name       = "dev"
  account              = "cms"
  project              = "batcave"
  owner                = "cms"
  iam_path             = "/delegatedadmin/developer/"
  permissions_boundary = "arn:aws:iam::373346310182:policy/cms-cloud-admin/developer-boundary-policy"
  event_schedule_cron  = "cron(0 9 * * ? *)" #11 PM Hawaii time
  log_retention        = 30 #CW logs retention in days
  lambda_timeout       = 300 # Lambda timeout in seconds
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids = ["${local.allowed_account_ids}"]
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${local.project}-${local.environment}-${local.aws_region}-tf-state"
    key    = format("${local.lambda_name}/%s/terraform.tfstate", path_relative_to_include())
    region = "${local.aws_region}"
    encrypt = true
  }
}

inputs = {
  aws_region = local.aws_region
  lambda_name = local.lambda_name
  environment          = local.environment
  directory_name       = local.directory_name
  account              = local.account
  project              = local.project
  owner                = local.owner
  iam_path             = local.iam_path
  permissions_boundary = local.permissions_boundary
  event_schedule_cron = local.event_schedule_cron
  log_retention       = local.log_retention
  lambda_timeout = local.lambda_timeout
}
