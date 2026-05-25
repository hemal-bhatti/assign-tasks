Task 1 — Infrastructure as Code (Foundation Layer)

Goal
Provision the complete AWS infrastructure using Terraform or CloudFormation, which will be
reused in subsequent tasks.
Requirements
Create AWS infrastructure with the following components:
• Networking
o VPC
o 2 Public Subnets (Multi-AZ)
o 2 Private Subnets (Multi-AZ)
o Internet Gateway
o NAT Gateway
o Route Tables
• Security
o Security Groups (ALB, App, Jenkins, Bastion if needed)
o Least-privilege IAM Roles
• Compute
o EC2 instance or ECS Cluster (candidate choice)
o Jenkins Master & Jenkins Agent (Agent must be separate)
• Storage
o S3 bucket for build artifacts / Terraform state

Deliverables
1. IaC Code
a. Terraform or CloudFormation templates
2. README.md
a. Architecture diagram (ASCII / draw.io acceptable)
b. Description of resources
c. Variables and defaults
d. How to:
i. Initialize
ii. Deploy
iii. Destroy infrastructure