# Copyright (C) 2022 Panther Labs Inc
#
# Panther Enterprise is licensed under the terms of a commercial license available from
# Panther Labs Inc ("Panther Commercial License") by contacting contact@runpanther.com.
# All use, distribution, and/or modification of this software, whether commercial or non-commercial,
# falls under the Panther Commercial License to the extent it is permitted.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# IAM roles for log ingestion from an S3 bucket
resource "aws_iam_role" "log_processing_role" {
  name = "PantherLogProcessingRole-${var.role_suffix}"

  path                 = var.role_path
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cms-cloud-admin/developer-boundary-policy"

  # Policy that grants an entity permission to assume the role.
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          AWS : "arn:${var.aws_partition}:iam::${var.panther_aws_account_id}:root"
        }
        Condition : {
          Bool : { "aws:SecureTransport" : true }
        }
      }
    ]
  })

  tags = {
    Application = "Panther"
  }
}


# Provides an IAM role inline policy for reading s3 Data
resource "aws_iam_role_policy" "read_data_policy" {
  name = "ReadData"
  role = aws_iam_role.log_processing_role.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
        ],
        Resource : [
          data.aws_s3_bucket.cms_logging_bucket.arn,
        ]
      },
      {
        Effect : "Allow",
        Action : "s3:GetObject",
        Resource : [
          "${data.aws_s3_bucket.cms_logging_bucket.arn}/*",
          "${aws_s3_bucket.gd_export_s3_bucket.arn}/*"
        ]
    }, ]
  })
}

# Provides an ARN that decrypts ciphertext that was encrypted by a KMS key
resource "aws_iam_role_policy" "kms_decryption" {
  name = "kmsDecryption"
  role = aws_iam_role.log_processing_role.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource : [
          aws_kms_key.kms_key.arn,
          data.aws_kms_alias.cloudtrail_kms_key.target_key_arn,
        ]
      }
    ]
  })
}
