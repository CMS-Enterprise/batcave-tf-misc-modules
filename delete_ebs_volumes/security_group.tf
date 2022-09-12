resource "aws_security_group" "lambda" {
  name        = "${var.lambda_name}-lambda"
  description = "Security group for ${var.lambda_name}"
  vpc_id      = data.aws_vpc.batcave_vpc.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda.id
}
