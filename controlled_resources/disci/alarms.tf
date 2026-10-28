# CloudWatch alarms → SNS topic → email to admin_email. One email when an alarm enters
# ALARM; alarms that treat missing data as fine return to OK on their own once the
# failures stop. Reading the logs behind an alarm: the app repo's docs/ops/deployment.md §2.3.
# Counts toward the account's free tier (10 alarms, 10 custom metrics): app repo docs/ops/cost.md.

resource "aws_sns_topic" "alarms" {
  name = "${local.name}-alarms"
}

# Stays "pending confirmation" until the link in AWS's confirmation email is clicked.
resource "aws_sns_topic_subscription" "alarms_email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.admin_email
}

# --- disci-jobs -------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "jobs_crashed" {
  alarm_name        = "${local.name}-jobs-crashed"
  alarm_description = "A disci-jobs run failed outright (DB unreachable, timeout, or a bug outside the per-user loop). Check /aws/lambda/disci-jobs for errorType."
  namespace         = "AWS/Lambda"
  metric_name       = "Errors"
  dimensions        = { FunctionName = aws_lambda_function.jobs.function_name }

  statistic           = "Sum"
  period              = 3600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

# The job catches a per-user failure and carries on, so it never shows as a Lambda error;
# the logged ERROR line is the only signal.
resource "aws_cloudwatch_log_metric_filter" "recurring_failures" {
  name           = "${local.name}-recurring-failures"
  log_group_name = aws_cloudwatch_log_group.jobs.name
  pattern        = "{ $.logger = \"app.jobs.recurring\" && $.level = \"ERROR\" }"

  metric_transformation {
    namespace = "Disci"
    name      = "RecurringFailures"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "jobs_user_failures" {
  alarm_name        = "${local.name}-jobs-user-failures"
  alarm_description = "Recurring generation failed for at least one user. The disci-jobs ERROR line carries user_id."
  namespace         = "Disci"
  metric_name       = "RecurringFailures"

  statistic           = "Sum"
  period              = 3600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  depends_on = [aws_cloudwatch_log_metric_filter.recurring_failures]
}

# The schedule is hourly; no invocation in 6 hours means it's disabled or broken. Missing
# data is the failure here, so it breaches. Also emails when it recovers.
resource "aws_cloudwatch_metric_alarm" "jobs_not_running" {
  alarm_name        = "${local.name}-jobs-not-running"
  alarm_description = "disci-jobs hasn't been invoked in 6 hours. Check the disci-recurring-transactions schedule in EventBridge Scheduler."
  namespace         = "AWS/Lambda"
  metric_name       = "Invocations"
  dimensions        = { FunctionName = aws_lambda_function.jobs.function_name }

  statistic           = "Sum"
  period              = 21600
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
}

# --- API (both disci-api and disci-mcp sit behind this HTTP API) -------------------

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name        = "${local.name}-api-5xx"
  alarm_description = "The HTTP API returned a 5xx (an unhandled exception, a Lambda crash or a timeout) on disci-api or disci-mcp. Check both log groups for errorType."
  namespace         = "AWS/ApiGateway"
  metric_name       = "5xx"
  dimensions = {
    ApiId = aws_apigatewayv2_api.main.id
    Stage = aws_apigatewayv2_stage.default.name
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}
