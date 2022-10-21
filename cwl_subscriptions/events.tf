# Events that match the following pattern
resource "aws_cloudwatch_event_rule" "rule" {
  name          = "CloudWatchLog-Group-Auto-Subscribe"
  description   = "Subscribes new eks and ec2 log groups to a kinesis stream"
  event_pattern = <<EOF
{
  "source": [
    "aws.logs"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "logs.amazonaws.com"
    ],
    "eventName": [
      "CreateLogGroup"
    ],
    "requestParameters": {
      "logGroupName": [
        { 
          "prefix": "/aws/eks/"
        }
      ]
    },
    "errorCode": [
      { 
        "exists": false
      }
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  target_id = aws_cloudwatch_event_rule.rule.name
  arn       = aws_sfn_state_machine.new_loggroup.arn
  role_arn  = aws_iam_role.event_loggroup.arn
}



###########################
###### Step Function ######
###########################

resource "aws_sfn_state_machine" "new_loggroup" {
  name       = "subscribe-to-firehose"
  role_arn   = aws_iam_role.sfn_new_loggroup.arn
  definition = <<EOF
{
  "Comment": "Subscribes log groups to a Firehose",
  "StartAt": "Subscribe",
  "States": {
    "Subscribe": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:cloudwatchlogs:putSubscriptionFilter",
      "Parameters": {
        "DestinationArn": "${aws_kinesis_firehose_delivery_stream.panther_firehose.arn}",
        "FilterName": "panther-firehose-filter",
        "FilterPattern": "",
        "RoleArn": "${aws_iam_role.cloudwatch_firehose_role.arn}",
        "LogGroupName.$": "$.detail.requestParameters.logGroupName"
      },
      "End": true
    }
  }
}
EOF
}
