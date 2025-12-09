provider "aws" {
  region = "us-east-1" # US East 1 is the standard for global endpoints
}

resource "aws_s3_bucket" "portfolio" {
  bucket = "yasanthamegasooriya.com" # MUST match your domain exactly
}

# 1. Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# 2. Disable "Block Public Access" (Required for public sites)
resource "aws_s3_bucket_public_access_block" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 3. Add Bucket Policy to allow public read
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.portfolio.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portfolio.arn}/*"
      },
    ]
  })
}

# Output the endpoint to use in Cloudflare
output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.portfolio.website_endpoint
}