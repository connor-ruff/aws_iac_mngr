resource "aws_lambda_layer_version" "google_api_python_client_layer" {
  layer_name  = "google-api-python-client-layer"
  description = "Allowing for Python 3.8"
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
  to = aws_lambda_layer_version.google_api_python_client_layer
  id = "arn:aws:lambda:${local.region}:${local.account_id}:layer:google-api-python-client-layer:2"
}
