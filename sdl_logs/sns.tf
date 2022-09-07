resource "aws_sns_topic" "panther_topic" {
  name              = "panther-notifications-topic"
  kms_master_key_id = aws_kms_alias.kms_key.arn
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.panther_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "sns:Subscribe",
      "sns:SetTopicAttributes",
      "sns:Receive",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.panther_topic.arn,
    ]

    sid = "sns"

  }

  statement {
    actions = [
      "sns:Subscribe",
      "sns:Receive",
      "sns:GetTopicAttributes",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.panther_aws_account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:sqs:us-east-1:${var.panther_aws_account_id}:panther-input-data-notifications-queue",
    ]

    sid = "lambda"

  }

  statement {
    actions = [
      "sns:Publish",
    ]

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com",
        "events.amazonaws.com",
      ]
    }

    resources = [
      aws_sns_topic.panther_topic.arn,
    ]

    sid = "allowS3Events"
  }

}

# Will panther subscribe it on its own?
resource "aws_sns_topic_subscription" "panther" {
  topic_arn = aws_sns_topic.panther_topic.arn
  protocol  = "sqs"
  endpoint  = "arn:aws:sqs:us-east-1:${var.panther_aws_account_id}:panther-input-data-notifications-queue"
}