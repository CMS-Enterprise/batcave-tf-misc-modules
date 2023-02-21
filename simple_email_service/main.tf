resource "aws_ses_email_identity" "email_identity" {
  count = var.create_email_identity ? 1 : 0
  email = var.email
}

resource "aws_ses_email_identity" "domain_identity" {
  count = var.create_domain_identity ? 1 : 0
  email = var.domain
}