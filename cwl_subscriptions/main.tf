data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "firehose_bucket" {
  bucket = "cms-cloud-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}
