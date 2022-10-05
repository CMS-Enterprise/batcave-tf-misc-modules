data "aws_iam_policy_document" "irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        var.oidc_arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${trim(var.oidc_url, "https://")}:sub"
      values = [
        "system:serviceaccount:${var.pod_namespace}:${var.pod_service_account}"
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
  name   = "dev_s3_read"
  path   = var.role_path
  policy = data.aws_iam_policy_document.s3.json
}
 
resource "aws_iam_role" "s3" {
  name               = "dev_s3_read"
  path               = var.role_path
  assume_role_policy = data.aws_iam_policy_document.irsa.json
  permissions_boundary = var.permissions_boundary
}
 
resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.s3.name
  policy_arn = aws_iam_policy.s3.arn
}