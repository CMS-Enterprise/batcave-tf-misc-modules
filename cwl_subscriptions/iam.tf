# firehose to s3 role
resource "aws_iam_role" "firehose_s3_role" {
  name                 = "${var.cluster_name}-FirehoseS3Role"
  path                 = var.iam_role_path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
  inline_policy {
    name = "panther-firehose-s3-policy"
    policy = jsonencode({
      "Version" : "2012-10-17"
      "Statement" : [
        {
          "Action" : [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ]
          "Effect" : "Allow"
          "Resource" : [
            data.aws_s3_bucket.firehose_bucket.arn,
            "${data.aws_s3_bucket.firehose_bucket.arn}/*",
          ]
        }
      ]
    })
  }
}

# Cloudwatch to firehose role
resource "aws_iam_role" "cloudwatch_firehose_role" {
  name                 = "${var.cluster_name}-CloudwatchFirehoseRole"
  path                 = var.iam_role_path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })

  inline_policy {
    name = "panther-cloudwatch-firehose-policy"
    policy = jsonencode({
      "Version" : "2012-10-17"
      "Statement" : [
        {
          "Action" : [
            "firehose:DescribeDeliveryStream",
            "firehose:PutRecord",
            "firehose:PutRecordBatch"
          ],
          "Effect" : "Allow",
          "Resource" : aws_kinesis_firehose_delivery_stream.panther_firehose.arn
        }
      ]
    })
  }
}

###########################
##### Eventbridge IAM #####
###########################

resource "aws_iam_role" "event_loggroup" {
  name                 = "new-loggroup-events-role"
  path                 = var.iam_role_path
  permissions_boundary = var.permissions_boundary

  inline_policy {
    name   = "log-group-events"
    policy = data.aws_iam_policy_document.events_policy.json

  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "events_policy" {
  statement {
    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = [aws_sfn_state_machine.new_loggroup.arn]
  }
}

# Step Function Role
resource "aws_iam_role" "sfn_new_loggroup" {
  name                 = "new-loggroup-sfn"
  path                 = var.iam_role_path
  permissions_boundary = var.permissions_boundary

  inline_policy {
    name   = "new-loggroup-sfn"
    policy = data.aws_iam_policy_document.sfn_policy.json

  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "sfn_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:PutSubscriptionFilter"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.cloudwatch_firehose_role.arn]
    condition {
      test     = "StringNotEquals"
      variable = "iam:PassedToService"

      values = [
        "logs.amazonaws.com",
      ]
    }
  }
}
