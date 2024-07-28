variable "vpc_id" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
  lower   = true
}

resource "null_resource" "update_frontend_urls" {
  provisioner "local-exec" {
    command = "${path.module}/../../scripts/update_urls.sh ../frontend/out ${var.backend_url}"
  }
}

#resource "null_resource" "upload_frontend_files" {
#  depends_on = [null_resource.update_frontend_urls, aws_s3_bucket.frontend_bucket, aws_s3_bucket_policy.s3_bucket_policy]
#
#  provisioner "local-exec" {
#    command = "aws s3 sync ../frontend/out s3://${aws_s3_bucket.frontend_bucket.bucket} --acl public-read"
#  }
#}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = format("aigoat-frontend-bucket-${random_string.suffix.result}")
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_bucket_encryption" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true

  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:PutBucketPolicy"
      ],
      "Resource": [
        "${aws_s3_bucket.frontend_bucket.arn}",
        "${aws_s3_bucket.frontend_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.public_access_allow]
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_allow" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_object" "frontend_bucket" {
  depends_on = [null_resource.update_frontend_urls]
  for_each = fileset("../frontend/out/", "**/*")
  bucket = aws_s3_bucket.frontend_bucket.id
  key    = each.value
  source = "../frontend/out/${each.value}"
#  etag   = filemd5("../frontend/out/${each.value}")
  content_type  = lookup(local.content_types, split(".", each.value)[length(split(".", each.value)) - 1], "text/html")
#  content_type = file_content_type(each.value)
  cache_control = "no-cache"

}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

}

# Helper function to determine content type based on file extension
locals {
  content_types = {
    "html" = "text/html"
    "js"   = "application/javascript"
    "css"  = "text/css"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    # Add more mappings as needed
  }
}