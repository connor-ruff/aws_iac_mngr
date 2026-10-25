# Triggers lambda-gdrive-to-snowflake-pipe with stkz (stock?) data config.
# Runs nightly at 11:30pm Chicago time. Currently disabled.
resource "aws_scheduler_schedule" "stkz_refresh" {
  name        = "stkz-refresh-scheduler-rule"
  description = "To trigger the lambda process to ingest stkz data"
  group_name  = "default"
  state       = "DISABLED"

  schedule_expression          = "cron(30 23 * * ? *)"
  schedule_expression_timezone = "America/Chicago"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 5
  }

  target {
    arn      = "arn:aws:lambda:${local.region}:${local.account_id}:function:lambda-gdrive-to-snowflake-pipe"
    role_arn = "arn:aws:iam::${local.account_id}:role/service-role/Amazon_EventBridge_Scheduler_LAMBDA_b817d5b32e"

    input = jsonencode({
      root_folder_id       = "1U34rVdX_mUuuvKj0HTcPKWo3PitDir9D"
      processed_folder_id  = "1sPqTF6CLDJHhuQq8j3zY-Zu84HpOCJFW"
      bucket_name          = "connors-big-money-data-bucket"
      key_name_base        = "upload/"
      sf_account           = "ei90710.us-east-2.aws"
      sf_warehouse         = "COMPUTE_WH"
      sf_database          = "STKZ"
      sf_schema            = "STG"
      sf_role              = "PROG_USER_ROLE"
      sf_stored_proc_name  = "LOAD_DAILY_FILES"
      convert_excel_ind    = "False"
      excel_sheet_name     = "null"
    })

    retry_policy {
      maximum_event_age_in_seconds = 86400
      maximum_retry_attempts       = 185
    }
  }
}

import {
  to = aws_scheduler_schedule.stkz_refresh
  id = "default/stkz-refresh-scheduler-rule"
}
