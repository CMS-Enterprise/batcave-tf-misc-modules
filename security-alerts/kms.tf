
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
        "cloudwatch.amazonaws.com"
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

## GuardDuty S3 Export KMS Key

data "aws_iam_policy_document" "gd_export_kms_key" {

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
    sid = "Allow GuardDuty to encrypt findings"
    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow key access for Panther"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${var.iam_role_path}PantherLogProcessingRole-${var.account_name}"
      ]
    }
  }

}

resource "aws_kms_key" "gd_export_kms_key" {
  deletion_window_in_days = 7
  description             = "GD S3 Export KMS Key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.gd_export_kms_key.json

}

resource "aws_kms_alias" "gd_export_kms_key" {
  name          = "alias/batcave-gd-export-s3"
  target_key_id = aws_kms_key.gd_export_kms_key.id
}
