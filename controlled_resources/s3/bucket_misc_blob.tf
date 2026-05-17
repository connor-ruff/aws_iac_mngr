# General-purpose blob storage. Used by multiple Lambdas: eBird data lands in
# ebird/, Zeta Ball data in zeta_ball/, and GDrive pipeline also writes here.
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

import {
  to = aws_s3_bucket.misc_blob
  id = "connors-misc-blob-for-blobs"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.misc_blob
  id = "connors-misc-blob-for-blobs"
}

import {
  to = aws_s3_bucket_public_access_block.misc_blob
  id = "connors-misc-blob-for-blobs"
}

resource "aws_s3_bucket_notification" "misc_blob_snowpipe" {
  bucket = aws_s3_bucket.misc_blob.id

  queue {
    id            = "snowpipe-kdp-combined-sales"
    queue_arn     = "arn:aws:sqs:us-east-2:735350675005:sf-snowpipe-AIDA2WNSQ2Y6V5Z4WP5TK-jbsX5hFOp6szLtrj6JRmQg"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "books/csv_stage/combined_sales/"
  }
}
