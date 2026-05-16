resource "aws_lambda_layer_version" "snowflake_connector_python_3_13" {
  layer_name = "snowflake-connector-python-3-13"
  filename   = "${path.module}/placeholder.zip"

  compatible_runtimes = ["python3.13"]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

import {
  to = aws_lambda_layer_version.snowflake_connector_python_3_13
  id = "arn:aws:lambda:${local.region}:${local.account_id}:layer:snowflake-connector-python-3-13:2"
}
