resource "aws_lambda_layer_version" "zeta_ball_api_to_sf" {
  layer_name = "zeta-ball-api-to-sf"
  filename   = "${path.module}/placeholder.zip"

  compatible_runtimes = [
    "python3.10",
    "python3.11",
    "python3.12",
    "python3.13",
  ]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

import {
  to = aws_lambda_layer_version.zeta_ball_api_to_sf
  id = "arn:aws:lambda:${local.region}:${local.account_id}:layer:zeta-ball-api-to-sf:1"
}
