
resource "aws_secretsmanager_secret" "slack_webhook" {
  name = "slack_webhook_url"
}

# resource "aws_secretsmanager_secret_version" "secret_version" {
#   secret_id     = aws_secretsmanager_secret.slack_webhook.id
#   secret_string = var.slack_webhook_secret
# }
