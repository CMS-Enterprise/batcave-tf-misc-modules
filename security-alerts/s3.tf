data "aws_iam_policy_document" "gd_export_s3_bucket" {
  statement {
    effect    = "allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.gd_export_s3_bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    effect    = "allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.gd_export_s3_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "gd_s3_export_bucket" {
  bucket = aws_s3_bucket.gd_export_s3_bucket.id
  policy = data.aws_iam_policy_document.gd_export_s3_bucket
}

resource "aws_s3_bucket" "gd_export_s3_bucket" {
  bucket = "batcave-gd-s3-export-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}