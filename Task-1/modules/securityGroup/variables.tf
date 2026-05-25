variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string } # <-- ADD THIS LINE
variable "environment" { type = string }
variable "artifact_bucket_name" { type = string }