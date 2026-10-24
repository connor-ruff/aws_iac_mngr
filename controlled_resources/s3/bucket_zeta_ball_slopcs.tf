# Public static website for the weekly SlopCS rankings. index.html is managed
# here; data/*.json is unloaded by Snowflake (STG.PUBLISH_SLOPCS) each week.
# Intentionally public-read — never put anything private in this bucket.
resource "aws_s3_bucket" "zeta_ball_slopcs" {
  bucket = "zeta-ball-slopcs"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "zeta_ball_slopcs" {
  bucket = aws_s3_bucket.zeta_ball_slopcs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.encryption_rule.apply_server_side_encryption_by_default.sse_algorithm
    }
    bucket_key_enabled = local.encryption_rule.bucket_key_enabled
  }
}

# ACLs stay blocked; only the bucket policy below grants public read.
resource "aws_s3_bucket_public_access_block" "zeta_ball_slopcs" {
  bucket                  = aws_s3_bucket.zeta_ball_slopcs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "zeta_ball_slopcs_public_read" {
  bucket = aws_s3_bucket.zeta_ball_slopcs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.zeta_ball_slopcs.arn}/*"
      }
    ]
  })

  # The policy is rejected while the public access block still blocks public policies
  depends_on = [aws_s3_bucket_public_access_block.zeta_ball_slopcs]
}

resource "aws_s3_bucket_website_configuration" "zeta_ball_slopcs" {
  bucket = aws_s3_bucket.zeta_ball_slopcs.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "zeta_ball_slopcs_index" {
  bucket        = aws_s3_bucket.zeta_ball_slopcs.id
  key           = "index.html"
  source        = "${path.module}/site_content/zeta-ball-slopcs/index.html"
  etag          = filemd5("${path.module}/site_content/zeta-ball-slopcs/index.html")
  content_type  = "text/html; charset=utf-8"
  cache_control = "no-cache"
}

output "zeta_ball_slopcs_website_url" {
  value = "http://${aws_s3_bucket_website_configuration.zeta_ball_slopcs.website_endpoint}"
}
