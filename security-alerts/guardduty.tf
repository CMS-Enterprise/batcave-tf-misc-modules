data "aws_guardduty_detector" "cms_cloud_gd" {}

resource "aws_guardduty_publishing_destination" "test" {
  detector_id     = aws_guardduty_detector.cms_cloud_gd.id
  destination_arn = aws_s3_bucket.cms_cloud_logs.arn
  kms_key_arn     = aws_kms_key.gd_key.arn
}

data "aws_s3_bucket" "cms_cloud_logs" {
  bucket = "cms-cloud-${data.aws_caller_identity.current.account_id}-us-east-1"
}