resource "aws_cloudwatch_log_metric_filter" "trend_metric" {
  name           = "TrendVirusDetection"
  pattern        = "virus found"
  log_group_name = data.aws_cloudwatch_log_group.trend_log_group.name

  metric_transformation {
    name      = "TrendVirusDetection"
    namespace = "Trend"
    value     = "1"
  }
}

data "aws_cloudwatch_log_group" "trend_log_group" {
  name = "/aws/ec2/var/opt/ds_agent/diag/ds_am.log"
}

resource "aws_cloudwatch_metric_alarm" "trend_alarm" {
  alarm_name          = "trend-virus-detection"
  metric_name         = aws_cloudwatch_log_metric_filter.trend_metric.name
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "Trend"
  alarm_actions       = [aws_sns_topic.slack_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "sechub_statemachine_alarm" {
  alarm_name          = "sechub_statemachine_alarm"
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  alarm_actions       = [aws_sns_topic.slack_topic.arn]
}