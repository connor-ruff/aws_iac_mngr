resource "aws_iam_role" "eventbridge_scheduler_lambda_b817d5b32e" {
  name        = "Amazon_EventBridge_Scheduler_LAMBDA_b817d5b32e"
  path        = "/service-role/"
  description = "Role created specifically for the scheduler that runs the stkz refresh lambda invocation"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "scheduler.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = { StringEquals = { "aws:SourceAccount" = local.account_id } }
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_scheduler_execution_gdrive_snowflake" {
  name = "Amazon-EventBridge-Scheduler-Execution-Policy-ee38df3a-b38e-4237-b807-2a5c99ba1ce3"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          "arn:aws:lambda:us-east-2:${local.account_id}:function:lambda-gdrive-to-snowflake-pipe:*",
          "arn:aws:lambda:us-east-2:${local.account_id}:function:lambda-gdrive-to-snowflake-pipe",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_b817d5b32e_execution" {
  role       = aws_iam_role.eventbridge_scheduler_lambda_b817d5b32e.name
  policy_arn = aws_iam_policy.eventbridge_scheduler_execution_gdrive_snowflake.arn
}

import {
  to = aws_iam_role.eventbridge_scheduler_lambda_b817d5b32e
  id = "Amazon_EventBridge_Scheduler_LAMBDA_b817d5b32e"
}

import {
  to = aws_iam_policy.eventbridge_scheduler_execution_gdrive_snowflake
  id = "arn:aws:iam::676058464455:policy/service-role/Amazon-EventBridge-Scheduler-Execution-Policy-ee38df3a-b38e-4237-b807-2a5c99ba1ce3"
}

import {
  to = aws_iam_role_policy_attachment.eventbridge_scheduler_b817d5b32e_execution
  id = "Amazon_EventBridge_Scheduler_LAMBDA_b817d5b32e/arn:aws:iam::676058464455:policy/service-role/Amazon-EventBridge-Scheduler-Execution-Policy-ee38df3a-b38e-4237-b807-2a5c99ba1ce3"
}
