resource "aws_lambda_layer_version" "api_basic_layer" {
  layer_name  = "api-basic-layer"
  description = "requests, xmltodict"
  filename    = "${path.module}/placeholder.zip"

  compatible_runtimes = [
    "python3.10",
    "python3.11",
    "python3.12",
    "python3.13",
  ]

  lifecycle {
    # compatible_runtimes included because the layer has python3.14 in AWS, which the
    # current provider version does not recognize — causes forced replacement without this.
    ignore_changes = [filename, source_code_hash, compatible_runtimes]
  }
}

import {
  to = aws_lambda_layer_version.api_basic_layer
  id = "arn:aws:lambda:${local.region}:${local.account_id}:layer:api-basic-layer:1"
}
