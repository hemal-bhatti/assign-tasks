terraform {
  backend "s3" {
    bucket  = "terrform-state-files-dev-prod-task1"
    key     = "dev/terraform.tfstate"
    region  = "ap-south-1"
    profile = "aim-dek"
  }
}
