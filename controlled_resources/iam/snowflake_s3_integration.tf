# Snowflake storage integration role. Trusted principal is the IAM user in
# Snowflake's AWS account (735350675005). The external ID is Snowflake-generated
# and must not be changed — it's what Snowflake sends when assuming this role.
resource "aws_iam_role" "s3_read_access_for_aws_accounts" {
  name        = "s3-read-access-for-aws-accounts"
  description = "originally created for the snowflake storage integration"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::735350675005:user/4cw40000-s" }
        Action    = "sts:AssumeRole"
        Condition = { StringEquals = { "sts:ExternalId" = "EI90710_SFCRole=2_crsmES5Bkhbwy1MZjWanUy06Dqk=" } }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_snowflake_readonly" {
  role       = aws_iam_role.s3_read_access_for_aws_accounts.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "s3_snowflake_fullaccess" {
  role       = aws_iam_role.s3_read_access_for_aws_accounts.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

import {
  to = aws_iam_role.s3_read_access_for_aws_accounts
  id = "s3-read-access-for-aws-accounts"
}

import {
  to = aws_iam_role_policy_attachment.s3_snowflake_readonly
  id = "s3-read-access-for-aws-accounts/arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

import {
  to = aws_iam_role_policy_attachment.s3_snowflake_fullaccess
  id = "s3-read-access-for-aws-accounts/arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
