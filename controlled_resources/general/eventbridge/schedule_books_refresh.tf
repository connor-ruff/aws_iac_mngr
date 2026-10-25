# Triggers lambda-gdrive-to-snowflake-pipe with books sales data config.
# Runs nightly at 11:00pm Chicago time. Currently disabled.
resource "aws_scheduler_schedule" "books_refresh" {
  name       = "books-refresh-scheduler-rule"
  group_name = "default"
  state      = "DISABLED"

  schedule_expression          = "cron(0 23 * * ? *)"
  schedule_expression_timezone = "America/Chicago"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 5
  }

  target {
    arn      = "arn:aws:lambda:${local.region}:${local.account_id}:function:lambda-gdrive-to-snowflake-pipe"
    role_arn = "arn:aws:iam::${local.account_id}:role/service-role/Amazon_EventBridge_Scheduler_LAMBDA_b817d5b32e"

    input = jsonencode({
      root_folder_id       = "1bvvg-c99z4E-CxltBEkHiWRxJrn3ow0d"
      processed_folder_id  = "1-3Y12HwqDAuCycYbEadF-OckU4wkZOiS"
      bucket_name          = "connors-misc-blob-for-blobs"
      key_name_base        = "books/upload/"
      sf_account           = "ei90710.us-east-2.aws"
      sf_warehouse         = "COMPUTE_WH"
      sf_database          = "BOOKS"
      sf_schema            = "STG"
      sf_role              = "PROG_USER_ROLE"
      sf_stored_proc_name  = "LOAD_COMBINED_SALES_FILES"
      convert_excel_ind    = "True"
      excel_sheet_name     = "Combined Sales"
    })

    retry_policy {
      maximum_event_age_in_seconds = 86400
      maximum_retry_attempts       = 185
    }
  }
}

import {
  to = aws_scheduler_schedule.books_refresh
  id = "default/books-refresh-scheduler-rule"
}
