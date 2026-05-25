output "bucket_name" {
  value       = aws_s3_bucket.artifacts.id 
  description = "The name/ID of the S3 bucket for Jenkins artifacts"
}