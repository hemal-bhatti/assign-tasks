module "vpc" {
  source               = "../../modules/vpc"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "securityGroup" {
  source               = "../../modules/securityGroup"
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  artifact_bucket_name = module.s3.bucket_name
  vpc_cidr             = var.vpc_cidr
}

module "ec2" {
  source                = "../../modules/ec2"
  environment           = var.environment
  instance_type         = var.instance_type
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  jenkins_master_sg_id  = module.securityGroup.jenkins_master_sg_id
  jenkins_agent_sg_id   = module.securityGroup.jenkins_agent_sg_id
  instance_profile_name = module.securityGroup.instance_profile_name
  ssh_key_name          = var.ssh_key_name
  bastion_sg_id         = module.securityGroup.bastion_sg_id
}

module "s3" {
  source      = "../../modules/s3"
  environment = var.environment
}
