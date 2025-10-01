
provider "aws" {
  region = var.region
}

# Network Module
module "network" {
  source = "./modules/network"
  
  region          = var.region
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet  = "10.0.4.0/24"
}

# Security Groups Module
module "security" {
  source = "./modules/security"
  
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
}

# Load Balancer Module
module "loadbalancer" {
  source = "./modules/loadbalancer"
  
  name_prefix      = var.name_prefix
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.public_subnet_ids
  security_group_id = module.security.alb_security_group_id
}

# MySQL Module
module "mysql" {
  source = "./modules/mysql"
  
  name_prefix      = var.name_prefix
  mysql_ami        = var.mysql_ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  subnet_id        = module.network.private_subnet_id
  security_group_id = module.security.mysql_security_group_id
}

# WordPress Module
module "wordpress" {
  source = "./modules/wordpress"
  
  name_prefix           = var.name_prefix
  wordpress_ami         = var.wordpress_ami
  instance_type         = var.instance_type
  key_name              = var.key_name
  security_group_id     = module.security.wp_security_group_id
  subnet_ids            = module.network.public_subnet_ids
  target_group_arns     = [module.loadbalancer.target_group_arn]
  mysql_private_ip      = module.mysql.private_ip
  max_size              = var.max_size
  min_size              = var.min_size
  desired_capacity      = var.desired_capacity
  cpu_scale_out_threshold = var.cpu_scale_out_threshold
  cpu_scale_in_threshold  = var.cpu_scale_in_threshold
}
