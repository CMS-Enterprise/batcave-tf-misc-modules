# Security hub generic
resource "aws_cloudwatch_event_rule" "rule" {
  name          = "sechub-findings-to-lambda"
  description   = "Sends Security Hub findings to a Slack Lambda"
  role_arn      = aws_iam_role.sfn_target_role.arn
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
      "ProductName": [ { "anything-but": [ "Inspector", "Default", "GuardDuty" ] } ]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  target_id = aws_cloudwatch_event_rule.rule.name
  arn       = aws_sfn_state_machine.sechub_state_machine.arn
  role_arn  = aws_iam_role.sfn_target_role.arn
}

# Security hub nessus only
# resource "aws_cloudwatch_event_rule" "nessus" {
#   name          = "sechub-findings-to-lambda-nessus"
#   description   = "Sends Security Hub nessus findings to a Slack Lambda"
#   role_arn      = aws_iam_role.sfn_target_role.arn
#   event_pattern = <<EOF
# {
#   "source": [
#     "aws.securityhub"
#   ],
#   "detail-type": [
#     "Security Hub Findings - Imported"
#   ],
#   "detail": {
#     "findings": {
#       "RecordState": ["ACTIVE"],
#       "WorkflowState": ["NEW"],
#       "Severity": {
#         "Label": [ "CRITICAL" ]
#       },
#       "ProductName": [ "Default" ]
#     }
#   }
# }
# EOF
# }

# resource "aws_cloudwatch_event_target" "nessus" {
#   rule      = aws_cloudwatch_event_rule.nessus.name
#   target_id = aws_cloudwatch_event_rule.nessus.name
#   arn       = aws_sfn_state_machine.sechub_state_machine.arn
#   role_arn  = aws_iam_role.sfn_target_role.arn
# }
