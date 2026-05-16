# Snowflake external function role. Used by Snowflake to call API Gateway
# endpoints. The role itself has no policies — access is granted via API Gateway
# resource policies. Two external IDs exist because this role is referenced by
# two separate Snowflake external functions.
resource "aws_iam_role" "sf_external_function" {
  name        = "sf-external-function-role"
  description = "Allows snowflake to use the API Gateway in AWS to invoke lambda functions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::735350675005:user/4cw40000-s" }
        Action    = "sts:AssumeRole"
        Condition = { StringEquals = { "sts:ExternalId" = "EI90710_SFCRole=2_WUwYWI+8yBA0hoSuomsElk7Adpo=" } }
      },
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::735350675005:user/4cw40000-s" }
        Action    = "sts:AssumeRole"
        Condition = { StringEquals = { "sts:ExternalId" = "EI90710_SFCRole=2_fq9o2EC/6+Iot9Qu48ZmNgRJxQA=" } }
      }
    ]
  })
}

import {
  to = aws_iam_role.sf_external_function
  id = "sf-external-function-role"
}
