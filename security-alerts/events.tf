# Security hub generic
resource "aws_cloudwatch_event_rule" "rule" {
  name        = "sechub-findings-to-lambda"
  description = "Sends Security Hub findings to a Slack Lambda"

  event_pattern = <<EOF
{
  "source": [
    "aws.securityhub"
  ],
  "detail-type": [
    "Security Hub Findings - Imported"
  ],
  "detail": {
  	"findings": {
      "Title": [ { "anything-but": [ "EC2.17 EC2 instances should not use multiple ENIs", "S3.8 S3 Block Public Access setting should be enabled at the bucket-level" ] } ],
  		"RecordState": ["ACTIVE"],
      "WorkflowState": ["NEW"],
      "Severity": {
        "Label": [ "CRITICAL", "HIGH" ]
      },
      "ProductName": [ { "anything-but": [ "Inspector", "Default" ] } ]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  target_id = aws_cloudwatch_event_rule.rule.name
  arn       = aws_sns_topic.slack_topic.id
}

# GuardDuty
resource "aws_cloudwatch_event_rule" "guardduty" {
  name        = "guardduty-findings-to-lambda"
  description = "Sends GuardDuty findings to a Slack Lambda"

  event_pattern = <<EOF
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ],
  "detail": {
    "severity": [
      { "numeric": [ ">", 3.9 ] }
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "guardduty" {
  rule      = aws_cloudwatch_event_rule.guardduty.name
  target_id = aws_cloudwatch_event_rule.guardduty.name
  arn       = aws_sns_topic.slack_topic.id
}
