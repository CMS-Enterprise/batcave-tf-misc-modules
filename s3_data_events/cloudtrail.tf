
resource "aws_cloudtrail" "main" {
  name = "${var.project}-${var.environment}-${data.aws_region.current.name}-data-events"

  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  is_multi_region_trail         = false
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
        "arn:aws:s3:::cms-cloud-${data.aws_caller_identity.current.account_id}-us-east-1/",
        "arn:aws:s3:::cms-cloud-${data.aws_caller_identity.current.account_id}-us-west-2/",
        "${aws_s3_bucket.cloudtrail.arn}/",
      ]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }
  }

}
