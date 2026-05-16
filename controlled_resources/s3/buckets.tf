locals {
  # Shared config applied to all buckets
  encryption_rule = {
    apply_server_side_encryption_by_default = {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ---
# connors-big-money-data-bucket
# Primary data bucket for the GDrive → Snowflake pipeline. Lambda writes
# processed files here; Snowflake reads them via the s3-read-access-for-aws-accounts role.
# ---

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

# ---
# connors-misc-blob-for-blobs
# General-purpose blob storage. Used by multiple Lambdas: eBird data lands in
# ebird/, Zeta Ball data in zeta_ball/, and GDrive pipeline also writes here.
# ---

resource "aws_s3_bucket" "misc_blob" {
  bucket = "connors-misc-blob-for-blobs"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "misc_blob" {
  bucket = aws_s3_bucket.misc_blob.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.encryption_rule.apply_server_side_encryption_by_default.sse_algorithm
    }
    bucket_key_enabled = local.encryption_rule.bucket_key_enabled
  }
}

resource "aws_s3_bucket_public_access_block" "misc_blob" {
  bucket                  = aws_s3_bucket.misc_blob.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ---
# connors-python-packages
# Stores Lambda deployment packages (zip files). Referenced by Lambda functions
# as their code source.
# ---

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
