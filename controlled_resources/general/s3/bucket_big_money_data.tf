# Primary data bucket for the GDrive → Snowflake pipeline. Lambda writes
# processed files here; Snowflake reads them via the s3-read-access-for-aws-accounts role.
resource "aws_s3_bucket" "big_money_data" {
  bucket = "connors-big-money-data-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "big_money_data" {
  bucket = aws_s3_bucket.big_money_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.encryption_rule.apply_server_side_encryption_by_default.sse_algorithm
    }
    bucket_key_enabled = local.encryption_rule.bucket_key_enabled
  }
}

resource "aws_s3_bucket_public_access_block" "big_money_data" {
  bucket                  = aws_s3_bucket.big_money_data.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

import {
  to = aws_s3_bucket.big_money_data
  id = "connors-big-money-data-bucket"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.big_money_data
  id = "connors-big-money-data-bucket"
}

import {
  to = aws_s3_bucket_public_access_block.big_money_data
  id = "connors-big-money-data-bucket"
}
