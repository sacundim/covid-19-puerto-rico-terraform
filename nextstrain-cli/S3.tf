resource "aws_s3_bucket" "jobs_bucket" {
  bucket = var.jobs_bucket_name

  tags = {
    Project = var.project_name
  }

  lifecycle_rule {
    id      = "Expire stale data"
    enabled = true

    expiration {
      days = 3
    }

    abort_incomplete_multipart_upload_days = 3
  }
}

resource "aws_s3_bucket_public_access_block" "block_jobs_bucket" {
  bucket = aws_s3_bucket.jobs_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
