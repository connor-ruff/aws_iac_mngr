# EventBridge Module

This module manages the EventBridge Scheduler schedules that trigger Lambda functions on a cron schedule.

## Schedules

| Terraform resource | Schedule name | Target | When | Status |
|---|---|---|---|---|
| `stkz_refresh` | `stkz-refresh-scheduler-rule` | `lambda-gdrive-to-snowflake-pipe` | Nightly 11:30pm Chicago | Disabled |
| `books_refresh` | `books-refresh-scheduler-rule` | `lambda-gdrive-to-snowflake-pipe` | Nightly 11:00pm Chicago | Disabled |
| `zeta_ball_api_pull` | `zeta-ball-api-pull` | `lambda-zeta-ball-api-to-sf` | Mondays 9:00pm Eastern | Disabled |

All three schedules are currently disabled in AWS and will remain so until explicitly re-enabled.

## How these work

Each schedule invokes `lambda-gdrive-to-snowflake-pipe` or `lambda-zeta-ball-api-to-sf` on a timer. The `input` field passes a JSON payload directly to the Lambda as its event — this is how the same GDrive Lambda handles two different pipelines (stkz vs. books): the payload tells it which GDrive folder to read, which S3 bucket to write to, and which Snowflake database/procedure to call.

The `flexible_time_window` means EventBridge can fire the schedule up to N minutes after the stated time. This avoids thundering-herd issues if multiple schedules fire at the same exact second.

## File structure

| File | Contents |
|---|---|
| `main.tf` | S3 backend + AWS provider |
| `schedules.tf` | `aws_scheduler_schedule` resources |
| `imports.tf` | Import blocks for all 3 schedules |
| `eventbridge.md` | This file |
