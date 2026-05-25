resource "aws_s3_bucket" "artifacts" {
  bucket        = "my-jenkins-artifacts-bucket-${var.environment}-unique-string" # S3 names must be globally unique
  force_destroy = true 

  tags = { Name = "${var.environment}-artifacts-bucket", Environment = var.environment }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}