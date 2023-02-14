resource "aws_sfn_state_machine" "sechub_state_machine" {
  name     = "sechub_state_machine"
  role_arn = aws_iam_role.sfn_sechub_role
  definition = jsonencode({
    Comment : "A description of my state machine",
    StartAt : "check if new or repeated finding from Nessus",
    States : {
      "New Finding Check" : {
        Type : "Choice",
        Choices : [
          {
            Variable : "$.detail.findings[0].FirstObservedAt",
            TimestampEqualsPath : "$.detail.findings[0].LastObservedAt",
            Next : "SNS Publish"
          }
        ],
        Default : "Success",
        Comment : "if this is the first time we have seen the finding { alert } else { suppress} "
      },
      "SNS Publish" : {
        Type : "Task",
        Resource : "arn:aws:states:::sns:publish",
        Parameters : {
          "Message.$" : "$",
          TopicArn : aws_sns_topic.slack_topic.arn
        },
        "End" : true,
        "Comment" : "Publish finding to slack"
      },
      "Success" : {
        "Type" : "Succeed"
      }
    }
  })
}