# Create S3 bucket
resource "aws_s3_bucket" "main-bucket" {
  count  = var.install-s3 ? 1 : 0
  bucket = "${local.environment-name}-bucket-${var.bucket-name}"

  tags = {
    Name        = "${local.environment-name}-bucket"
    Environment = "${local.environment-name}-env"
  }
}
resource "aws_s3_bucket_acl" "main-bucket-private" {
  count  = var.install-s3 ? 1 : 0
  bucket = aws_s3_bucket.main-bucket.*.id[count.index]
  acl    = "private"
}
resource "aws_s3_bucket_public_access_block" "main-bucket-restrict-public" {
  count                   = var.install-s3 ? 1 : 0
  bucket                  = aws_s3_bucket.main-bucket.*.id[count.index]
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
