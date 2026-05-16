resource "aws_lambda_layer_version" "snowflake_lambda_layer_from_youtube" {
  layer_name  = "snowflake-lambda-layer-from-youtube"
  description = ".zip file used in layer was obtained from youtube video: https://www.youtube.com/watch?v=3faTmvqui5g&ab_channel=KnowledgeAmplifier"
  filename    = "${path.module}/placeholder.zip"

  compatible_runtimes      = ["python3.8"]
  compatible_architectures = ["x86_64"]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

import {
  to = aws_lambda_layer_version.snowflake_lambda_layer_from_youtube
  id = "arn:aws:lambda:${local.region}:${local.account_id}:layer:snowflake-lambda-layer-from-youtube:1"
}
