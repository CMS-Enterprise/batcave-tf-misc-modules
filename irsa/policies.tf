data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  dns_suffix = data.aws_partition.current.dns_suffix
}

################################################################################
# SOPS Policy
################################################################################
data "aws_iam_policy_document" "sops" {
  count = var.create_role && var.attach_sops_policy ? 1 : 0

  statement {
    sid = "kmslist"
    actions = [
      "kms:List*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid = "kmsops"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
    ]
    resources = [var.sops_arn]
  }
}

resource "aws_iam_policy" "sops" {
  count = var.create_role && var.attach_sops_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}${var.app_name}_Policy-"
  path        = var.role_path
  description = "View and decrypt KMS keys"
  policy      = data.aws_iam_policy_document.sops[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sops" {
  count = var.create_role && var.attach_sops_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.sops[0].arn
}

################################################################################
# S3 Policy
################################################################################
data "aws_iam_policy_document" "s3" {
  count = var.create_role && var.attach_s3_policy ? 1 : 0

  statement {
    sid = "S3ReadWrite"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = [for bucket in var.s3_bucket_arns : "${bucket}/*"]
  }

  statement {
    sid = "S3List"
    actions = [
      "s3:ListBucket",
    ]
    resources = var.s3_bucket_arns
  }
}

resource "aws_iam_policy" "s3" {
  count = var.create_role && var.attach_s3_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}${var.app_name}-"
  path        = var.role_path
  description = "Interact with S3"
  policy      = data.aws_iam_policy_document.s3[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  count = var.create_role && var.attach_s3_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.s3[0].arn
}

################################################################################
# DynamoDB Policy
################################################################################
data "aws_iam_policy_document" "dynamodb" {
  count = var.create_role && var.attach_dynamodb_policy ? 1 : 0

  # permissions taken from: https://developer.hashicorp.com/vault/docs/configuration/storage/dynamodb
  statement {
    sid = "DynamoDBReadWrite"
    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]
    resources = [var.dynamodb_arn]
  }
}

resource "aws_iam_policy" "dynamodb" {
  count = var.create_role && var.attach_dynamodb_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}${var.app_name}-"
  path        = var.role_path
  description = "Interact with DynamoDB"
  policy      = data.aws_iam_policy_document.dynamodb[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  count = var.create_role && var.attach_dynamodb_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.dynamodb[0].arn
}

################################################################################
# AWS Secrets Manager Policy
################################################################################
data "aws_iam_policy_document" "secrets-manager" {
  count = var.create_role &&  var.attach_secretsmanager_policy ? 1 : 0

  statement {
    sid = "SecretsManagerRead"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = var.secret_arns
  }
}

resource "aws_iam_policy" "secrets-manager" {
  count = var.create_role && var.attach_secretsmanager_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}${var.app_name}-"
  path        = var.role_path
  description = "Interact with Secrets Manager"
  policy      = data.aws_iam_policy_document.secrets-manager[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets-manager" {
  count = var.create_role && var.attach_secretsmanager_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.secrets-manager[0].arn
}

################################################################################
# AWS RDS Policy
################################################################################
data "aws_iam_policy_document" "rds" {
  count = var.create_role &&  var.attach_rds_policy ? 1 : 0

  statement {
    sid = "RdsConnect"
    actions = [
      "rds-db:connect"
    ]
    resources = var.rds_arns
  }
}

resource "aws_iam_policy" "rds" {
  count = var.create_role && var.attach_rds_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}${var.app_name}-"
  path        = var.role_path
  description = "Interact with RDS"
  policy      = data.aws_iam_policy_document.rds[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds" {
  count = var.create_role && var.attach_rds_policy ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.rds[0].arn
}