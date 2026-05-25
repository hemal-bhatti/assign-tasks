# Task 1 - Infrastructure as Code Foundation Layer

This project provisions an AWS foundation layer with Terraform. The code is organized into reusable modules and environment-specific configurations for `Dev` and `Prod`.

The infrastructure includes networking, security groups, IAM permissions, EC2 instances for Jenkins, and an S3 bucket for Jenkins build artifacts.

## Project Structure

```text
.
|-- environments
|   |-- Dev
|   |   |-- backend.tf
|   |   |-- main.tf
|   |   |-- provider.tf
|   |   |-- terraform.tfvars
|   |   `-- variables.tf
|   `-- Prod
|       |-- backend.tf
|       |-- main.tf
|       |-- provider.tf
|       |-- terraform.tfvars
|       `-- variables.tf
`-- modules
    |-- ec2
    |-- s3
    |-- securityGroup
    `-- vpc
```

## Architecture Diagram

```text
                                  Internet
                                      |
                                      v
                            Internet Gateway
                                      |
                      +---------------+---------------+
                      |                               |
              Public Subnet AZ-1              Public Subnet AZ-2
                      |                               |
              Jenkins Master EC2               Bastion Host EC2
              Port 8080 via ALB SG             SSH access
                      |
                      v
                Jenkins Agent traffic

                      +---------------+---------------+
                      |                               |
             Private Subnet AZ-1             Private Subnet AZ-2
                      |                               |
              Jenkins Agent EC2              Node App / Agent EC2
                      |                               |
                      +---------------+---------------+
                                      |
                                      v
                              NAT Gateway
                                      |
                                      v
                                  Internet

        Jenkins EC2 instances use an IAM instance profile for S3 access.
        S3 stores Jenkins build artifacts and has versioning enabled.
```

## Resources Created

### Networking

- VPC with DNS support and DNS hostnames enabled.
- 2 public subnets across available Availability Zones.
- 2 private subnets across available Availability Zones.
- Internet Gateway for public subnet internet access.
- Elastic IP and NAT Gateway for private subnet outbound internet access.
- Public route table with `0.0.0.0/0` routed to the Internet Gateway.
- Private route table with `0.0.0.0/0` routed to the NAT Gateway.

### Security

- ALB security group allowing inbound HTTP traffic on port `80`.
- Bastion security group allowing inbound SSH on port `22`.
- Jenkins master security group:
  - Allows Jenkins UI traffic on port `8080` from the ALB security group.
  - Allows SSH on port `22` from the bastion security group.
  - Allows Jenkins agent traffic on port `50000` from the VPC CIDR.
- Jenkins agent security group:
  - Allows SSH on port `22` from the bastion security group.
  - Allows outbound traffic for package downloads and Jenkins communication.
- IAM role and instance profile for Jenkins EC2 instances.
- IAM policy allowing Jenkins instances to read, write, and list the artifacts S3 bucket.

> Note: The code currently creates an ALB security group, but it does not create an actual Application Load Balancer resource.

### Compute

- Jenkins master EC2 instance in a public subnet.
- Bastion host EC2 instance in a public subnet.
- Jenkins agent EC2 instance in a private subnet.
- Additional private EC2 instance tagged as a node application / Jenkins agent.
- Latest Ubuntu 22.04 LTS AMI is selected dynamically.

### Storage

- S3 bucket for Jenkins build artifacts.
- S3 bucket versioning enabled.
- `force_destroy = true` is enabled so Terraform can delete the bucket and its objects during destroy.

### Remote State

Terraform state is configured to use an S3 backend:

- Dev state key: `dev/terraform.tfstate`
- Prod state key: `prod/terraform.tfstate`
- Backend bucket: `terrform-state-files-dev-prod-task1`
- Backend region: `ap-south-1`

The backend bucket must already exist before running `terraform init`.

## Variables and Defaults

### Environment Variables

| Variable | Description | Dev Default | Prod Default |
| --- | --- | --- | --- |
| `aws_region` | AWS region variable declared for the environment | `ap-south-1` | `ap-south-1` |
| `environment` | Environment name used in resource names and tags | `dev` | `prod` |
| `instance_type` | EC2 instance type | `t3.micro` | `t3.medium` |
| `vpc_cidr` | CIDR block for the VPC | `10.0.0.0/16` | `10.0.0.0/16` |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `["10.0.3.0/24", "10.0.4.0/24"]` | `["10.0.3.0/24", "10.0.4.0/24"]` |
| `ssh_key_name` | Existing AWS EC2 key pair name for SSH access | `Hemal's` | `Hemal's` |

### Module Variables

| Module | Variables |
| --- | --- |
| `vpc` | `environment`, `vpc_cidr`, `public_subnet_cidrs`, `private_subnet_cidrs` |
| `securityGroup` | `environment`, `vpc_id`, `vpc_cidr`, `artifact_bucket_name` |
| `ec2` | `environment`, `instance_type`, `public_subnet_ids`, `private_subnet_ids`, `jenkins_master_sg_id`, `jenkins_agent_sg_id`, `bastion_sg_id`, `instance_profile_name`, `ssh_key_name` |
| `s3` | `environment` |

## Prerequisites

- Terraform installed.
- AWS CLI configured with the `aim-dek` profile.
- Existing S3 bucket for Terraform remote state: `terrform-state-files-dev-prod-task1`.
- Existing EC2 key pair matching `ssh_key_name`; update the value if your key pair uses a different name.
- AWS permissions to create VPC, EC2, IAM, security group, route table, NAT Gateway, EIP, and S3 resources.

The provider is currently configured in both environments to use:

```hcl
profile = "aim-dek"
region  = var.aws_region
```

## How to Initialize

Run Terraform from the environment directory you want to deploy.

### Dev

```bash
cd environments/Dev
terraform init
```

### Prod

```bash
cd environments/Prod
terraform init
```

## How to Deploy

### Dev

```bash
cd environments/Dev
terraform plan
terraform apply
```

### Prod

```bash
cd environments/Prod
terraform plan
terraform apply
```

Review the plan output before approving the apply.

## How to Destroy Infrastructure

### Dev

```bash
cd environments/Dev
terraform destroy
```

### Prod

```bash
cd environments/Prod
terraform destroy
```

Destroying the infrastructure removes the Terraform-managed resources. Because the artifacts S3 bucket has `force_destroy = true`, Terraform can also delete objects stored in that bucket.

## Useful Commands

Format Terraform files:

```bash
terraform fmt -recursive
```

Validate an environment:

```bash
cd environments/Dev
terraform validate
```

Show outputs and state:

```bash
terraform output
terraform state list
```
