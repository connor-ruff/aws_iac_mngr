resource "aws_lambda_layer_version" "pandas_layer" {
  layer_name  = "pandas-layer"
  description = "Includes: pandas and openpyxl"
  filename    = "${path.module}/placeholder.zip"

  compatible_runtimes = [
    "python3.8",
    "python3.9",
    "python3.10",
  ]

  compatible_architectures = ["x86_64"]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

import {
  to = aws_lambda_layer_version.pandas_layer
  id = "arn:aws:lambda:${local.region}:${local.account_id}:layer:pandas-layer:2"
}
