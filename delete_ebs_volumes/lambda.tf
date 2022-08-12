data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/lambda_function.py"
  output_path = "${path.module}/python/lambda_function.py.zip"
}

resource "aws_lambda_function" "delete_ebs_volumes" {

  function_name    = var.lambda_name
  role             = aws_iam_role.delete_ebs_volumes_lambda_role.arn
  filename         = data.archive_file.lambda.output_path
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  timeout          = var.lambda_timeout
  tags = {
    environment = var.environment
    project     = var.project
  }
}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.delete_ebs_volumes.function_name}"
  retention_in_days = var.log_retention
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_event_rule" "delete_ebs_volumes_event_rule" {
  name                = "delete_ebs_volumes_event_rule"
  description         = "Event rule to trigger delete_ebs_volumes lambda everyday at 11 PM Hawaii time"
  schedule_expression = var.event_schedule_cron
}

resource "aws_cloudwatch_event_target" "delete_ebs_volumes_event_target" {
  rule      = aws_cloudwatch_event_rule.delete_ebs_volumes_event_rule.name
  target_id = "delete_ebs_volumes"
  arn       = aws_lambda_function.delete_ebs_volumes.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_ebs_volumes.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.delete_ebs_volumes_event_rule.arn
}

resource "aws_iam_role" "delete_ebs_volumes_lambda_role" {
  name                 = "delete_ebs_volumes_lambda_role"
  path                 = var.iam_path
  permissions_boundary = var.permissions_boundary
  managed_policy_arns  = [aws_iam_policy.delete_ebs_volumes_lambda_policy.arn]
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
}

resource "aws_iam_policy" "delete_ebs_volumes_lambda_policy" {
  name        = "delete_ebs_volumes_lambda_policy"
  path        = var.iam_path
  description = "Policy to be used by lambda which deletes available EBS volumes"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "EBSVolume",
          "Action" : [
            "ec2:DeleteVolume",
            "ec2:DescribeVolumeStatus",
            "ec2:DescribeVolumes"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Sid" : "CloudWatchLogs",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:logs:*:*:*"
        }
      ]
    }
  )
}
