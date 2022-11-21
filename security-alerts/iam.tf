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
