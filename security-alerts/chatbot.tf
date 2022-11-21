resource "awscc_chatbot_slack_channel_configuration" "chatbot" {
  configuration_name = "batcave-security-alerts"
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  slack_channel_id   = "C036GQ3E9D1"
  slack_workspace_id = "TGYJGRB1T"
  guardrail_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  logging_level      = "INFO"
  sns_topic_arns     = [aws_sns_topic.slack_topic.arn]
  user_role_required = false
}
