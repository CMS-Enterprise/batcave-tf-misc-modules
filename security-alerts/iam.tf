### chatbot
resource "aws_iam_role" "chatbot_role" {
  name                 = "sechub-findings-chatbot"
  path                 = var.iam_role_path
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cms-cloud-admin/developer-boundary-policy"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "chatbot.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "chatbot_policy" {
  statement {
    actions = [
      "autoscaling:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:Create*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Get*",
      "logs:List*",
      "logs:Describe*",
      "logs:TestMetricFilter",
      "logs:FilterLogEvents",
      "sns:Get*",
      "sns:List*"
    ]

    effect = "Allow"

    resources = [
      "*",
    ]

    sid = "chatbot"
  }
  statement {
    actions = [
      "chatbot:Describe*",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]

    sid = "chatbotSlack"
  }
}

resource "aws_iam_role_policy_attachment" "chatbot_attach" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = aws_iam_policy.chatbot_policy.arn
}

resource "aws_iam_policy" "chatbot_policy" {
  name        = "sechub-findings-chatbot"
  path        = var.iam_role_path
  description = "Allows chatbot to get sns"

  policy = data.aws_iam_policy_document.chatbot_policy.json
}

### Step Function Role

resource "aws_iam_role" "sfn_sechub_role" {
  name                 = "sfn_sechub_role"
  path                 = var.iam_role_path
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cms-cloud-admin/developer-boundary-policy"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : [
            "states.amazonaws.com"
          ]
        },
        Action : "sts:AssumeRole",
        Condition : {
          ArnLike : {
            "aws:SourceArn" : "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.step_function_name}"
          },
          StringEquals : {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
    }
  )

}

data "aws_iam_policy_document" "sfn_sechub_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.slack_topic.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    resources = [
      aws_kms_key.kms_key.arn
    ]
  }
}

# eventbridge sfn target role

resource "aws_iam_role" "sfn_target_role" {
  name                 = "sfn_target_role"
  path                 = var.iam_role_path
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cms-cloud-admin/developer-boundary-policy"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : [
            "events.amazonaws.com"
          ]
        },
        Action : "sts:AssumeRole",
        Condition : {
          ArnLike : {
            "aws:SourceArn" : ["arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule:${var.sechub_rule_name}",
              "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule:${var.sechub_nessus_rule_name}"
            ]
          },
          StringEquals : {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "sfn_target_policy" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution",
    ]
    resources = ["arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.step_function_name}"]
  }
}