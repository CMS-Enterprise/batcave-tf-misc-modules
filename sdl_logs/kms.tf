# Cloudtrail KMS key
data "aws_kms_alias" "cloudtrail_kms_key" {
  name = "alias/cms-cloud-${data.aws_caller_identity.current.account_id}"
}

# SNS Topic KMS Key
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
        "s3.amazonaws.com",
        "sns.amazonaws.com",
        "events.amazonaws.com",
      ]
    }
  }
}

resource "aws_kms_key" "kms_key" {
  deletion_window_in_days = 7
  description             = "batCAVE Panther SNS Topic KMS Key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key.json

}

resource "aws_kms_alias" "kms_key" {
  name          = "alias/batcave-panther"
  target_key_id = aws_kms_key.kms_key.id
}