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
  arn       = aws_sfn_state_machine.sechub_state_machine
}

# Security hub nessus only
resource "aws_cloudwatch_event_rule" "nessus" {
  name        = "sechub-findings-to-lambda-nessus"
  description = "Sends Security Hub nessus findings to a Slack Lambda"

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
      "RecordState": ["ACTIVE"],
      "WorkflowState": ["NEW"],
      "Severity": {
        "Label": [ "CRITICAL" ]
      },
      "ProductName": [ "Default" ]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "nessus" {
  rule      = aws_cloudwatch_event_rule.nessus.name
  target_id = aws_cloudwatch_event_rule.nessus.name
  arn       = aws_sfn_state_machine.sechub_state_machine
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
