data "aws_caller_identity" "current" {}

# ROLES
resource "aws_iam_role" "api-service-role" {
  name = "${var.GroupName}-api-service-role"
  depends_on = [
      aws_iam_policy.api-policy
    ]
  path = var.iam_role_path
  permissions_boundary = var.permissions_boundary
  tags = var.tags
  assume_role_policy = <<-EOF
  { 
    "Version": "2012-10-17",
    "Statement": [
      {
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Effect": "Allow",
          "Principal" : {
            "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${var.OIDCProviderID}"
          },
          "Condition": {
            "StringEquals": {
              "oidc.eks.us-east-1.amazonaws.com/id/${var.OIDCProviderID}:aud": "sts.amazonaws.com",
              "oidc.eks.us-east-1.amazonaws.com/id/${var.OIDCProviderID}:sub": "system:serviceaccount:${var.GroupName}:${var.GroupName}-api-service-account"
              }
          }
      }]
    }
      EOF
}

resource "aws_iam_role" "job-scheduler-service-role" {
  name = "${var.GroupName}-job-scheduler-service-role"
  depends_on = [
      aws_iam_policy.job-scheduler-policy
    ]
  path = var.iam_role_path
  permissions_boundary = var.permissions_boundary
  tags = var.tags
  assume_role_policy = <<-EOF
  { 
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Effect": "Allow",
        "Principal" : {
            "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${var.OIDCProviderID}"
        },
        "Condition": {
            "StringEquals": {
            "oidc.eks.us-east-1.amazonaws.com/id/${var.OIDCProviderID}:aud": "sts.amazonaws.com",
            "oidc.eks.us-east-1.amazonaws.com/id/${var.OIDCProviderID}:sub": "system:serviceaccount:${var.GroupName}:${var.GroupName}-job-scheduler-service-account"
            }
        }
    }]
  }
    EOF
}

resource "aws_iam_role" "cms-cloud-s3-snowflake-role" {
  name = "cms-cloud-${var.GroupName}-s3-snowflake-role"
  depends_on = [
      aws_iam_policy.snowflake-access-policy
    ]
  path = var.iam_role_path
  permissions_boundary = var.permissions_boundary
  tags = var.tags
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": 
    [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${var.SDLUserArn}"
          },
        "Action": [
          "sts:AssumeRole"
          ],
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": "${var.SDLExternalId}"
            }
          }  
      }
    ]
  }                  
  EOF
}

resource "aws_iam_policy" "api-policy" {
  name        = "${var.GroupName}-api-policy"
  path        = "/delegatedadmin/developer/"
  tags        = var.tags

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement":
    [
      {
        "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:ListBucket",
            "sqs:GetQueueUrl",
            "sqs:DeleteMessage",
            "sqs:ReceiveMessage",
            "sqs:SendMessage",
            "sqs:GetQueueAttributes"
            ],
          "Resource": ${local.ApiResources}
      }
    ]
  }
  EOF
}

locals {
  ApiResources = "[\"${join("\",\"",var.ApiResources)}\"]"
}

resource "aws_iam_policy" "job-scheduler-policy" {
  name        = "${var.GroupName}-job-scheduler-policy"
  path        = "/delegatedadmin/developer/"
  tags        = var.tags

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement":
    [
      {
      "Effect": "Allow",
        "Action": [
          "sqs:SendMessage",
          "sqs:GetQueueUrl"
          ],
        "Resource":
          ["${var.SQSStackName}"]
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "snowflake-access-policy" {
  name        = "${var.GroupName}-snowflake-access-policy"
  path        = "/delegatedadmin/developer/"
  tags        = var.tags

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement":
    [
      {
        "Effect": "Allow",
          "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:DeleteObject"
            ],
          "Resource":
            ["${var.S3StackName}"]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "snowflake_policy" {
  role       = aws_iam_role.cms-cloud-s3-snowflake-role.name
  policy_arn = aws_iam_policy.snowflake-access-policy.arn
}

resource "aws_iam_role_policy_attachment" "api_policy" {
  role       = aws_iam_role.api-service-role.name
  policy_arn = aws_iam_policy.api-policy.arn
}

resource "aws_iam_role_policy_attachment" "job_scheduler_policy" {
  role       = aws_iam_role.job-scheduler-service-role.name
  policy_arn = aws_iam_policy.job-scheduler-policy.arn
}
