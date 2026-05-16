resource "aws_api_gateway_rest_api" "snowflake_ext_func" {
  name        = "snowflake-ext-func-trigger"
  description = "This will be used for all Snowflake external functions that are designed to trigger an AWS lambda function"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  # Resource policy: allows sf-external-function-role (assumed by Snowflake) to
  # invoke both POST routes.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:sts::${local.account_id}:assumed-role/sf-external-function-role/snowflake" }
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-zeta-ball-refresh"
      },
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:sts::${local.account_id}:assumed-role/sf-external-function-role/snowflake" }
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:${local.region}:${local.account_id}:${local.api_id}/*/POST/lambda-ebird-general-refresher"
      }
    ]
  })
}

import {
  to = aws_api_gateway_rest_api.snowflake_ext_func
  id = "1dmrv6cveg"
}
