resource "aws_sns_topic" "slack_topic" {
  name              = "sechub_slack_lambda"
  kms_master_key_id = aws_kms_alias.kms_key.arn
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.slack_topic.arn

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
      aws_sns_topic.slack_topic.arn,
    ]

    sid = "sns"

  }

  statement {
    actions = [
      "sns:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.slack_topic.arn,
    ]

    sid = "allowCW"
  }

}
