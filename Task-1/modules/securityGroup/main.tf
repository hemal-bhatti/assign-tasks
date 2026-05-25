# modules/security/main.tf

# ==========================================
# 1. APPLICATION LOAD BALANCER SECURITY GROUP
# ==========================================
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allow public HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 2. BASTION HOST SECURITY GROUP (NEW!)
# ==========================================
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Allow SSH access to Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In real-world prod, replace with your specific office/home public IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 3. JENKINS MASTER SECURITY GROUP
# ==========================================
resource "aws_security_group" "jenkins_master" {
  name        = "${var.environment}-jenkins-master-sg"
  vpc_id      = var.vpc_id

  # Traffic from ALB to Jenkins UI Dashboard
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH access to Master from the Bastion host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Inbound JNLP traffic from agents (Port 50000) securely restricted to the VPC CIDR
  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Secure upgrade: only allowed from internal network
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 4. JENKINS AGENTS/SLAVES SECURITY GROUP
# ==========================================
resource "aws_security_group" "jenkins_agent" {
  name        = "${var.environment}-jenkins-agent-sg"
  vpc_id      = var.vpc_id

  # Allow administrative SSH connection only from the Bastion Host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id] # Fixed & isolated!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 5. IAM ROLES & PROFILES (Unchanged)
# ==========================================
resource "aws_iam_role" "jenkins_role" {
  name = "${var.environment}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${var.environment}-jenkins-s3-policy"
  role = aws_iam_role.jenkins_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.artifact_bucket_name}",
          "arn:aws:s3:::${var.artifact_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.environment}-jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}