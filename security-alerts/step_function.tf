resource "aws_sfn_state_machine" "sechub_state_machine" {
  name     = var.step_function_name
  role_arn = aws_iam_role.sfn_sechub_role.arn
  definition = jsonencode({
    Comment : "This state machine attempts to reduce duplicate alerts that have the same FirstObservedAt date for a given finding.",
    StartAt : "Prevent NULL detail info",
    States : {
      "Prevent NULL detail info" : {
        Type : "Choice",
        Choices : [
          {
            And : [
              {
                Variable : "$.detail",
                IsNull : false
              },
              {
                Variable : "$.detail",
                IsPresent : true
              },
              {
                Variable : "$.detail.findings",
                IsNull : false
              },
              {
                Variable : "$.detail.findings",
                IsPresent : true
              },
              {
                Variable : "$.detail.findings[0].FirstObservedAt",
                IsNull : false
              },
              {
                Variable : "$.detail.findings[0].FirstObservedAt",
                IsPresent : true
              },
              {
                Variable : "$.detail.findings[0].LastObservedAt",
                IsNull : false
              },
              {
                Variable : "$.detail.findings[0].LastObservedAt",
                IsPresent : true
              }              
            ]
            Next : "New Finding Check"
          }
        ]
        Default : "SNS Publish"
      }
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
        Comment : "if this is the first time we have seen the finding { alert } else { suppress } "
      },
      "Success" : {
        "Type" : "Succeed"
      }
    }
    "SNS Publish" : {
        Type : "Task",
        Resource : "arn:aws:states:::sns:publish",
        Parameters : {
          "Message.$" : "$",
          TopicArn : aws_sns_topic.slack_topic.arn
        },
        "End" : true,
        "Comment" : "Publish finding to slack"
    }
  })
}