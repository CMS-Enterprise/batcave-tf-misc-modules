
resource "aws_cloudwatch_event_rule" "rule" {
  name        = "logs-to-panther"
  description = "Sends bucket object create events to SNS"

  event_pattern = <<EOF
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "Object Created"
  ],
  "detail": {
  	"bucket": {
        "name": ["${data.aws_s3_bucket.cms_logging_bucket.id}"]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  target_id = aws_cloudwatch_event_rule.rule.name
  arn       = aws_sns_topic.panther_topic.id

  input_transformer {
    input_paths = {
      bucket  = "$.detail.bucket.name",
      object  = "$.detail.object",
      region  = "$.region"
      time    = "$.time"
      account = "$.account"
    }
    input_template = <<EOF
{
    "Records": [
        {
            "eventVersion":"2.2",
            "eventSource":"aws:s3",
            "awsRegion":<region>,
            "eventTime":<time>,
            "eventName":"PutObject",
            "s3":{  
                "s3SchemaVersion":"1.0",
                "bucket":{  
                    "name":"${data.aws_s3_bucket.cms_logging_bucket.id}",
                    "arn":"${data.aws_s3_bucket.cms_logging_bucket.arn}"
                },
                "object": <object>
            }
        }
    ]
}
EOF
  }
}