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
              # The isPresent check needs to be called first.
              # The isNull check will fail with an error if the key/value pair isn't present.
              # This was the opposite behavior that was expected.
              {
                Variable : "$.detail.findings[0].FirstObservedAt",
                IsPresent : true
              },
              {
                Variable : "$.detail.findings[0].LastObservedAt",
                IsPresent : true
              },
              {
                Variable : "$.detail.findings[0].FirstObservedAt",
                IsNull : false
              },
              {
                Variable : "$.detail.findings[0].LastObservedAt",
                IsNull : false
              }
            ]
            Next : "New Finding Check"
          }
        ],
        Default : "Success"
      },
      "New Finding Check" : {
        Type : "Choice",
        Choices : [
          {
            Variable : "$.detail.findings[0].FirstObservedAt",
            TimestampEqualsPath : "$.detail.findings[0].LastObservedAt",
            Next : "Transform"
          }
        ],
        Default : "Success",
        Comment : "if this is the first time we have seen the finding { alert } else { suppress } "
      },
      "Transform" : {
        Type : "Task"
        Resource : "arn:aws:states:::lambda:invoke",
        Parameters : {
          FunctionName : aws_lambda_function.transform-lambda.function_name
          "Payload.$" : "$",
          Qualifier : "$LATEST"
        },
        ResultPath : "$",
        OutputPath : "$.Payload"
        Next : "SNS Publish"
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