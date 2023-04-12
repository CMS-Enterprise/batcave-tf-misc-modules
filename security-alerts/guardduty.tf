data "aws_guardduty_detector" "cms_cloud_gd" {}

resource "aws_guardduty_publishing_destination" "s3-export" {
  detector_id     = data.aws_guardduty_detector.cms_cloud_gd.id
  destination_arn = "${data.aws_s3_bucket.cms_cloud_logs.arn}/guardduty/"
  kms_key_arn     = aws_kms_key.gd_export_kms_key.arn
}

data "aws_s3_bucket" "cms_cloud_logs" {
  bucket = "cms-cloud-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}