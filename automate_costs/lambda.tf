# Create a Lambda function
resource "aws_lambda_function" "s3_update_lambda" {
  filename      = "python/lambda_function.zip" # Path to your Lambda deployment package
  function_name = "cms-batcave-cost-data-batcave-dev-update"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  # Specify the S3 bucket and object key that the Lambda function will update
  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
      OBJECT_KEY  = var.object_key
    }
  }
  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids         = data.aws_subnets.private.ids
  }

  # Define the Lambda function's source code
  source_code_hash = filebase64sha256("python/lambda_function.zip") # Replace with your deployment package
}

# Create a CloudWatch Event Target for the Lambda function
resource "aws_cloudwatch_event_target" "schedule_lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "schedule_lambda_target"
  arn       = aws_lambda_function.s3_update_lambda.arn # Corrected the reference
}

# Create a CloudWatch Event Rule for scheduling
resource "aws_cloudwatch_event_rule" "schedule" {
  name        = "cms-batcave-cost-data-batcave-dev-schedule"
  description = "Schedule for Lambda Function"
  schedule_expression = "cron(00 00 * * ? *)"
}

# Create an IAM policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_read_write_policy"
  description = "IAM policy for read and write access to an S3 bucket"
  path        = var.iam_path

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::${var.bucket_name}",
        ],
      },
    ],
  })
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_access_role"
  path                 = var.iam_path
  managed_policy_arns  = [aws_iam_policy.s3_access_policy.arn]
  permissions_boundary  = var.role_permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}
