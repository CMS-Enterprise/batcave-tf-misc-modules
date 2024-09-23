data "aws_s3_bucket" "cms_logging_bucket" {
  bucket = "cms-cloud-${data.aws_caller_identity.current.account_id}-us-east-1"
}


# Bucket notifications are managed as a single resource by AWS.
# If an organizational change is made from cms cloud, our notifications will be overwritten, and if we
# make a change, we overwrite their settings, so this became a last resort
# This local-exec requires aws cli on the local machine
# Grabs the current bucket notification configuration and ensures
# .EventBridgeConfiguration = {} is present. An empty JSON object means this setting is enabled.
resource "null_resource" "bucket_notification" {
  triggers = {
    notification_configuration = data.external.bucket_notification.result["eventbridge"]
  }
  provisioner "local-exec" {
    command = tobool(data.external.bucket_notification.result["eventbridge"]) ? "echo blank" : "aws s3api put-bucket-notification-configuration --bucket ${data.aws_s3_bucket.cms_logging_bucket.id} --notification-configuration \"$(aws s3api get-bucket-notification-configuration --bucket ${data.aws_s3_bucket.cms_logging_bucket.id} --output json | jq '.EventBridgeConfiguration = {}')\""
  }
}

# this has some custom jq because the external provider cant deal with arrays in json objects and lambdaconfig is an array
# it is the trigger for the bucket notification code above to check if it needs to overwrite
data "external" "bucket_notification" {
  program = ["sh", "-c", "aws s3api get-bucket-notification-configuration --bucket ${data.aws_s3_bucket.cms_logging_bucket.id} --output json | jq -r '.EventBridgeConfiguration |if .==null then {\"eventbridge\":\"false\"} else {\"eventbridge\":\"true\"} end'"]
}

data "aws_iam_policy_document" "gd_export_s3_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.gd_export_s3_bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.gd_export_s3_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.gd_export_s3_bucket.arn,
      "${aws_s3_bucket.gd_export_s3_bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "gd_s3_export_bucket" {
  bucket = aws_s3_bucket.gd_export_s3_bucket.id
  policy = data.aws_iam_policy_document.gd_export_s3_bucket.json
}

resource "aws_s3_bucket" "gd_export_s3_bucket" {
  bucket = "batcave-gd-s3-export-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}

resource "aws_s3_bucket_notification" "panther_bucket_notifications" {
  bucket = aws_s3_bucket.gd_export_s3_bucket.id

  topic {
    topic_arn = aws_sns_topic.panther_topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
