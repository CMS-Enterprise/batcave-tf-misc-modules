resource "aws_iam_openid_connect_provider" "oidc_issuer" {
  url             = var.oidc_url
  thumbprint_list = [var.thumbprint]
  client_id_list  = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.oidc_issuer.arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${trim("${var.oidc_url}", "https://")}:sub"
      values = [
        "system:serviceaccount:default:test-s3-sa"
      ]
    }
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3" {
  name   = "test_s3_read"
  path   = var.role_path
  policy = data.aws_iam_policy_document.s3.json
}
 
resource "aws_iam_role" "s3" {
  name               = "test_s3_read"
  path               = var.role_path
  assume_role_policy = data.aws_iam_policy_document.irsa.json
  permissions_boundary = var.permissions_boundary
}
 
resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.s3.name
  policy_arn = aws_iam_policy.s3.arn
}