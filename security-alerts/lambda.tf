data "archive_file" "transform-lambda-package" {
  type        = "zip"
  source_file = "code/sechub_transform"
  output_path = "package.zip"
}

data "aws_iam_policy_document" "transform_trust_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "transform-role" {
  assume_role_policy = data.aws_iam_policy_document.transform_trust_policy.json
}

data "aws_iam_policy_document" "transform-role-policy-document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy_attachment" "transform-role-policy-attachment" {
  name       = "transform-role-policy-attachment"
  roles      = [aws_iam_role.transform-role.name]
  policy_arn = aws_iam_policy.transform-role-policy.arn

}

resource "aws_iam_policy" "transform-role-policy" {
  policy = data.aws_iam_policy_document.transform-role-policy-document.json
}

resource "aws_lambda_function" "transform-lambda" {
  function_name    = "transform-lambda"
  filename         = "package.zip"
  runtime          = "python3.9"
  handler          = "sechub_transform.handler"
  role             = aws_iam_role.transform-role.arn
  memory_size      = 256
  timeout          = 120
  source_code_hash = data.archive_file.transform-lambda-package.output_base64sha256
  environment {
    variables = {
        ACCOUNT_NAME = var.account_name
    }
  }
}