output "bucket_name" {
  # Replace 'artifacts' with whatever the actual resource nickname is inside your S3 module main.tf
  value       = aws_s3_bucket.artifacts.id 
  description = "The name/ID of the S3 bucket for Jenkins artifacts"
}