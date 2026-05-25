data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ==========================================
# PUBLIC SUBNET RESOURCES
# ==========================================

# 1. Jenkins Master (Public Subnet AZ-1)
resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.jenkins_master_sg_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.ssh_key_name

  tags = {
    Name        = "${var.environment}-jenkins-master"
    Environment = var.environment
  }
}

# 2. Bastion Host (Public Subnet AZ-2 for High Availability)
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type # Usually t2.micro / t3.micro suffices for Bastion
  subnet_id              = var.public_subnet_ids[1] 
  vpc_security_group_ids = [var.bastion_sg_id] # Requires bastion_sg_id passed via variables
  key_name               = var.ssh_key_name

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = var.environment
  }
}


# ==========================================
# PRIVATE SUBNET RESOURCES (Jenkins Slaves)
# ==========================================

# 3. Jenkins Agent / Slave 1 (Private Subnet AZ-1)
resource "aws_instance" "jenkins_agent_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.jenkins_agent_sg_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.ssh_key_name

  tags = {
    Name        = "${var.environment}-jenkins-agent-1"
    Environment = var.environment
  }
}

# 4. Jenkins Agent / Slave 2 (Private Subnet AZ-2)
resource "aws_instance" "jenkins_agent_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[1]
  vpc_security_group_ids = [var.jenkins_agent_sg_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.ssh_key_name

  tags = {
    Name        = "${var.environment}-node-application"
    Environment = var.environment
  }
}