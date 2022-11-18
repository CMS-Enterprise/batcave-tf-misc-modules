data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "cloudtrail_kms_key" {
  name = "alias/cms-cloud-${data.aws_caller_identity.current.account_id}"
}
