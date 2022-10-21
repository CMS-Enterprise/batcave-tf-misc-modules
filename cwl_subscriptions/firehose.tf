resource "aws_kinesis_firehose_delivery_stream" "panther_firehose" {
  name        = "${var.cluster_name}-PantherFirehose"
  destination = "extended_s3"

  extended_s3_configuration {
    bucket_arn      = data.aws_s3_bucket.firehose_bucket.arn
    buffer_size     = var.buffer_size
    buffer_interval = var.buffer_interval_in_seconds
    role_arn        = aws_iam_role.firehose_s3_role.arn

    prefix              = "cloudwatchlogs/"
    error_output_prefix = "cloudwatchlogs/error/"

    # dynamic partitioning will not work because cloudwatch logs are gzip'ed to the firehose
    # replace this with a lambda that extracts at some point

    # dynamic_partitioning_configuration {
    #   enabled = true
    # }

    # processing_configuration {
    #   enabled = "true"

    #   processors {
    #     type = "MetadataExtraction"
    #     parameters {
    #       parameter_name  = "JsonParsingEngine"
    #       parameter_value = "JQ-1.6"
    #     }
    #     parameters {
    #       parameter_name  = "MetadataExtractionQuery"
    #       parameter_value = "{log_group:.logGroup,log_stream:.logStream}"
    #     }
    #   }
    # }
  }
}
