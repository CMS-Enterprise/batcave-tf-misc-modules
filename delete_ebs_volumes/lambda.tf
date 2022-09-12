resource "null_resource" "lambda_package" {
  provisioner "local-exec" {
    command     = "docker run --rm -v \"$(pwd):/src\" -w /src python:3-alpine ./build.sh"
    working_dir = "${path.module}/python"
  }
  triggers = {
    # re-build when requirements change
    deps      = filemd5("${path.module}/python/requirements.txt")
    # re-build when source code changes
    source    = jsonencode({for f in fileset("${path.module}/python/", "*.py") : f => filemd5("${path.module}/python/${f}")})
    # re-build if the build output is missing locally or inconsistent with the latest deployed build
    build_log = fileexists("${path.module}/python/build.log") ? filemd5("${path.module}/python/build.log") : timestamp()
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/python/build"
  output_path = "${path.module}/lambda.zip"

  depends_on = [null_resource.lambda_package]
}

resource "aws_lambda_function" "delete_ebs_volumes" {
  function_name    = var.lambda_name
  role             = aws_iam_role.delete_ebs_volumes_lambda_role.arn
  filename         = data.archive_file.lambda.output_path
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  timeout          = var.lambda_timeout
  tags             = {
    environment = var.environment
    project     = var.project
  }
  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids         = data.aws_subnets.private.ids
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
  assume_role_policy   = jsonencode(
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
  policy      = jsonencode(
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
          "Sid" : "EKSCluster",
          "Action" : [
            "eks:AccessKubernetesApi",
            "eks:DescribeCluster",
            "eks:ListClusters"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Sid" : "VPCAndCloudWatch",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        }
      ]
    }
  )
}
