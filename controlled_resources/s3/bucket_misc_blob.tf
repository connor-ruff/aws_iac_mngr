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
