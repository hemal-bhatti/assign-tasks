
variable "aws_region" {}
variable "environment" {}
variable "instance_type" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "ssh_key_name" { type = string }
