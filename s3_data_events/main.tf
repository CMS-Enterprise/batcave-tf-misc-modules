data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "cloudtrail_kms_key" {
  name = "alias/cms-cloud-${data.aws_caller_identity.current.account_id}"
}

data "aws_s3_bucket" "cms_logging_bucket_east" {
  bucket = "cms-cloud-${data.aws_caller_identity.current.account_id}-us-east-1"
}

data "aws_s3_bucket" "cms_logging_bucket_west" {
  bucket = "cms-cloud-${data.aws_caller_identity.current.account_id}-us-west-2"
}
