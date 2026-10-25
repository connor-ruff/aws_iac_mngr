# Stores Lambda deployment packages (zip files). Referenced by Lambda functions
# as their code source.
resource "aws_s3_bucket" "python_packages" {
  bucket = "connors-python-packages"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "python_packages" {
  bucket = aws_s3_bucket.python_packages.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.encryption_rule.apply_server_side_encryption_by_default.sse_algorithm
    }
    bucket_key_enabled = local.encryption_rule.bucket_key_enabled
  }
}

resource "aws_s3_bucket_public_access_block" "python_packages" {
  bucket                  = aws_s3_bucket.python_packages.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

import {
  to = aws_s3_bucket.python_packages
  id = "connors-python-packages"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.python_packages
  id = "connors-python-packages"
}

import {
  to = aws_s3_bucket_public_access_block.python_packages
  id = "connors-python-packages"
}
