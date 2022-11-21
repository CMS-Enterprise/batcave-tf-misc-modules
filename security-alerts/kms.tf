
data "aws_iam_policy_document" "kms_key" {

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "chatbot.amazonaws.com",
      ]
    }
  }
}

resource "aws_kms_key" "kms_key" {
  deletion_window_in_days = 7
  description             = "batCAVE Sec Alerting SNS Topic KMS Key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key.json

}

resource "aws_kms_alias" "kms_key" {
  name          = "alias/batcave-sec-alerts"
  target_key_id = aws_kms_key.kms_key.id
}
