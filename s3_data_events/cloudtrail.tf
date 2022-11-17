
resource "aws_cloudtrail" "main" {
  name = "${var.project}-${var.environment}-data-events"

  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = data.aws_kms_alias.cloudtrail_kms_key.target_key_arn
  include_global_service_events = false


  advanced_event_selector {
    name = "Log all S3 objects events except for the log buckets"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field = "resources.ARN"

      not_equals = [
        "${data.aws_s3_bucket.cms_logging_bucket_east.arn}/",
        "${data.aws_s3_bucket.cms_logging_bucket_west.arn}/",
        "${aws_s3_bucket.cloudtrail.arn}/",
      ]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }
  }

}
