# S3 buckets for landing zone
resource "aws_s3_bucket" "cloutrail" {
  bucket        = "${var.project}-${var.environment}-${data.aws_region.current.name}-data-events"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "landing_zone_buckets" {
  bucket = aws_s3_bucket.cloudtrail.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "landing_zone_buckets" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "policy"
    Statement = [
      {
        Sid       = "EnforceTls"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.cloudtrail.arn}/*",
          aws_s3_bucket.cloudtrail.arn,
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "MinimumTlsVersion"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.cloudtrail.arn}/*",
          aws_s3_bucket.cloudtrail.arn,
        ]
        Condition = {
          NumericLessThan = {
            "s3:TlsVersion" = "1.2"
          }
        }
      },
      {
        Sid    = "cloudtrail"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.cloudtrail.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "CloudtrailCheckACL"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "s3:GetBucketAcl"
        Resource = [
          aws_s3_bucket.cloudtrail.arn,
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
