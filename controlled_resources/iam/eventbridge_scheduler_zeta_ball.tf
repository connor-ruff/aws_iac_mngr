resource "aws_iam_role" "eventbridge_scheduler_lambda_4c0ff2a8d0" {
  name = "Amazon_EventBridge_Scheduler_LAMBDA_4c0ff2a8d0"
  path = "/service-role/"

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

resource "aws_iam_policy" "eventbridge_scheduler_execution_zeta_ball" {
  name = "Amazon-EventBridge-Scheduler-Execution-Policy-febc3626-1730-446a-ac49-caa00b3236ad"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          "arn:aws:lambda:us-east-2:${local.account_id}:function:lambda-zeta-ball-api-to-sf:*",
          "arn:aws:lambda:us-east-2:${local.account_id}:function:lambda-zeta-ball-api-to-sf",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_4c0ff2a8d0_execution" {
  role       = aws_iam_role.eventbridge_scheduler_lambda_4c0ff2a8d0.name
  policy_arn = aws_iam_policy.eventbridge_scheduler_execution_zeta_ball.arn
}

import {
  to = aws_iam_role.eventbridge_scheduler_lambda_4c0ff2a8d0
  id = "Amazon_EventBridge_Scheduler_LAMBDA_4c0ff2a8d0"
}

import {
  to = aws_iam_policy.eventbridge_scheduler_execution_zeta_ball
  id = "arn:aws:iam::676058464455:policy/service-role/Amazon-EventBridge-Scheduler-Execution-Policy-febc3626-1730-446a-ac49-caa00b3236ad"
}

import {
  to = aws_iam_role_policy_attachment.eventbridge_scheduler_4c0ff2a8d0_execution
  id = "Amazon_EventBridge_Scheduler_LAMBDA_4c0ff2a8d0/arn:aws:iam::676058464455:policy/service-role/Amazon-EventBridge-Scheduler-Execution-Policy-febc3626-1730-446a-ac49-caa00b3236ad"
}
