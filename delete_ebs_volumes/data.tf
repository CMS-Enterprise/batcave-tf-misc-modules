data "aws_vpc" "batcave_vpc" {
  tags = {
    Name = "${var.project}-*-${var.environment}"
  }
}

# private subnets
data "aws_subnets" "private" {
  filter {
    name = "tag:Name"
    values = [
      "${var.project}-*-${var.environment}-private-*"
    ]
  }
}
