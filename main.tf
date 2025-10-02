

locals {
  wordpress_ami = data.aws_ami.wordpress.id != "" ? data.aws_ami.wordpress.id : data.aws_ami.wordpress_fallback.id
  mysql_ami     = data.aws_ami.ubuntu.id
}

# Network Module
module "network" {
  source = "./modules/network"
  project_name = var.project_name
  region = var.region
  vpc_cidr = var.vpc_cidr

  # Use the new subnets_list structure
  subnets_list = var.subnets_list
}

# Security Groups Module
module "security" {
  source = "./modules/security-groups"
  
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
  
  security_groups = [
    {
      name        = "alb"
      description = "Security group for Application Load Balancer"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP access"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    },
    {
      name        = "web"
      description = "Security group for web servers"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP access"
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "SSH access"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    },
    {
      name        = "database"
      description = "Security group for database servers"
      ingress_rules = [
        {
          from_port        = 3306
          to_port          = 3306
          protocol         = "tcp"
          security_groups  = []  # Will be updated after creation
          description      = "MySQL access from web servers"
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "SSH access"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
  ]
}

resource "aws_security_group_rule" "database_from_web" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.security.security_group_ids["web"]
  security_group_id        = module.security.security_group_ids["database"]
  description              = "MySQL access from web servers"
}

# Load Balancer Module
module "loadbalancer" {
  source = "./modules/loadbalancer"
  
  name_prefix      = var.name_prefix
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.public_subnet_ids
  security_group_id = module.security.security_group_ids["alb"]
  
  load_balancer_name = "alb"
  target_group_name  = "tg"
  internal          = false
}

# MySQL Module
module "mysql" {
  source = "./modules/ec2"
  
  name_prefix      = var.name_prefix
  ami              = local.mysql_ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  subnet_id        = module.network.private_subnet_ids[0]
  security_group_ids = [module.security.security_group_ids["database"]]
  instance_name    = "MySQL-Server"
  
  # MySQL user data
  user_data = <<-EOF
#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== Starting MySQL Configuration ==="

# Update and install MySQL
apt-get update
apt-get install -y mysql-server

# Start MySQL
systemctl start mysql
systemctl enable mysql

echo "MySQL installed, waiting for initialization..."
sleep 30

# Check if MySQL is running
echo "Checking MySQL status..."
systemctl status mysql

# Configure MySQL for remote access
echo "Configuring MySQL for remote access..."
if [ -f /etc/mysql/mysql.conf.d/mysqld.cnf ]; then
    sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "Updated mysqld.cnf"
else
    echo "mysqld.cnf not found, checking other config files..."
    find /etc/mysql -name "*.cnf" -exec grep -l "bind-address" {} \;
fi

# Restart MySQL
echo "Restarting MySQL..."
systemctl restart mysql
echo "MySQL restarted, waiting..."
sleep 10

# Test MySQL connection
echo "Testing MySQL connection..."
mysql -e "SELECT 1;" || echo "MySQL connection failed"

# Create database and user
echo "Creating database and user..."
mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;" || echo "Failed to create database"
mysql -e "DROP USER IF EXISTS 'admin'@'%';" || echo "Failed to drop user"
mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'Pass1234';" || echo "Failed to create remote user"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'admin'@'%';" || echo "Failed to grant privileges to remote user"
mysql -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Pass1234';" || echo "Failed to create local user"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'admin'@'localhost';" || echo "Failed to grant privileges to local user"
mysql -e "FLUSH PRIVILEGES;" || echo "Failed to flush privileges"

# Verify
echo "Verifying setup..."
mysql -e "SELECT User, Host FROM mysql.user WHERE User='admin';" > /tmp/mysql_users.log 2>&1
mysql -e "SHOW DATABASES;" > /tmp/mysql_databases.log 2>&1

echo "=== MySQL Configuration Complete ==="
echo "Check /var/log/user-data.log for full details"
EOF
}

# WordPress ASG 
module "wordpress" {
  source = "./modules/asg"
  
  name_prefix      = var.name_prefix
  ami              = local.wordpress_ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  security_group_ids = [module.security.security_group_ids["web"]]
  subnet_ids       = module.network.public_subnet_ids
  target_group_arns = [module.loadbalancer.target_group_arn]
  instance_name    = "WordPress-Instance"
  
  # WordPress user data
  user_data = <<-EOF
#!/bin/bash
# Update WordPress configuration with MySQL details
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '${module.mysql.private_ip}' );/" /var/www/html/wp-config.php

# Start Apache
systemctl start apache2
systemctl enable apache2
EOF
  
  # ASG configuration
  max_size              = var.max_size
  min_size              = var.min_size
  desired_capacity      = var.desired_capacity
  health_check_type     = "ELB"
  health_check_grace_period = 300
  
  # Scaling configuration
  cpu_scale_out_threshold = var.cpu_scale_out_threshold
  cpu_scale_in_threshold  = var.cpu_scale_in_threshold
  enable_scaling_policies = true
  
  # Additional tags
  additional_tags = {
    Application = "WordPress"
    Environment = "Production"
  }
}
