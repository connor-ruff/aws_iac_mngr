# Triggers lambda-zeta-ball-api-to-sf every Monday at 9pm Eastern.
# Currently disabled.
resource "aws_scheduler_schedule" "zeta_ball_api_pull" {
  name       = "zeta-ball-api-pull"
  group_name = "default"
  state      = "DISABLED"

  schedule_expression          = "cron(0 21 ? * MON *)"
  schedule_expression_timezone = "America/New_York"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 10
  }

  target {
    arn      = "arn:aws:lambda:${local.region}:${local.account_id}:function:lambda-zeta-ball-api-to-sf"
    role_arn = "arn:aws:iam::${local.account_id}:role/service-role/Amazon_EventBridge_Scheduler_LAMBDA_4c0ff2a8d0"

    retry_policy {
      maximum_event_age_in_seconds = 86400
      maximum_retry_attempts       = 0
    }
  }
}

import {
  to = aws_scheduler_schedule.zeta_ball_api_pull
  id = "default/zeta-ball-api-pull"
}
