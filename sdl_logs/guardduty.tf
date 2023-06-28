data "aws_guardduty_detector" "cms_cloud_gd" {}

resource "aws_guardduty_publishing_destination" "s3-export" {
  detector_id     = data.aws_guardduty_detector.cms_cloud_gd.id
  destination_arn = "${aws_s3_bucket.gd_export_s3_bucket.arn}/guardduty/"
  kms_key_arn     = aws_kms_key.gd_export_kms_key.arn
}

resource "aws_s3_object" "guardduty_directory" {
  bucket = aws_s3_bucket.gd_export_s3_bucket.id
  key    = "guardduty/"
}