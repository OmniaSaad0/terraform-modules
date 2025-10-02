# FortStack Terraform Infrastructure

A modular, reusable Terraform infrastructure project for deploying scalable web applications on AWS. This project demonstrates best practices for infrastructure as code with generic, composable modules.

## 🏗️ Architecture Overview

This project creates a complete WordPress + MySQL infrastructure with the following components:

- **VPC** with public and private subnets across multiple AZs
- **Application Load Balancer** for high availability
- **Auto Scaling Group** for WordPress instances
- **MySQL Database** on EC2 with automated setup
- **Security Groups** with proper network isolation
- **CloudWatch Monitoring** with auto-scaling policies

## 📁 Project Structure

```
fortstack-terrform/
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── data.tf                    # Data sources for AMI lookups
├── backend.tf                 # S3 backend configuration
├── terraform.tfvars.example   # Example variable values
├── README.md                  # This file
└── modules/                   # Reusable Terraform modules
    ├── network/               # VPC, subnets, routing
    ├── ec2/                   # Generic EC2 instances
    ├── asg/                   # Generic Auto Scaling Groups
    ├── loadbalancer/          # Generic Application Load Balancers
    └── security-groups/       # Generic Security Groups
```

## 🧩 Modules

### 1. Network Module (`modules/network/`)

Creates the foundational networking infrastructure.

**Resources:**
- VPC with DNS support
- Public and private subnets (configurable)
- Internet Gateway
- NAT Gateway with Elastic IP
- Route tables and associations

**Key Features:**
- Dynamic subnet creation using `for_each`
- Configurable subnet types (public/private)
- Automatic route table associations
- Multi-AZ support

**Usage:**
```hcl
module "network" {
  source = "./modules/network"
  
  project_name = "my-project"
  region       = "us-west-1"
  vpc_cidr     = "10.0.0.0/16"
  
  subnets_list = [
    {
      name              = "public_subnet1"
      cidr              = "10.0.1.0/24"
      type              = "public"
      availability_zone = "us-west-1a"
    },
    {
      name              = "private_subnet1"
      cidr              = "10.0.4.0/24"
      type              = "private"
      availability_zone = "us-west-1a"
    }
  ]
}
```

### 2. EC2 Module (`modules/ec2/`)

Generic module for creating single EC2 instances.

**Resources:**
- EC2 instance with configurable AMI and instance type
- Optional user data support
- Flexible security group assignment

**Key Features:**
- Optional user data (plain text or base64)
- Configurable instance naming
- Additional tags support
- All standard EC2 outputs

**Usage:**
```hcl
module "mysql" {
  source = "./modules/ec2"
  
  name_prefix      = "my-project"
  ami              = "ami-12345678"
  instance_type    = "t3.small"
  key_name         = "my-key"
  subnet_id        = module.network.private_subnet_ids[0]
  security_group_ids = [module.security.security_group_ids["database"]]
  instance_name    = "MySQL-Server"
  
  user_data = <<-EOF
#!/bin/bash
# Custom setup script
EOF
}
```

### 3. ASG Module (`modules/asg/`)

Generic module for creating Auto Scaling Groups.

**Resources:**
- Launch template
- Auto Scaling Group
- CloudWatch alarms (CPU-based)
- Scaling policies (scale out/in)

**Key Features:**
- Configurable scaling thresholds
- Optional scaling policies
- Target group integration
- Health check configuration
- Flexible user data support

**Usage:**
```hcl
module "web_app" {
  source = "./modules/asg"
  
  name_prefix      = "my-project"
  ami              = "ami-12345678"
  instance_type    = "t3.small"
  key_name         = "my-key"
  security_group_ids = [module.security.security_group_ids["web"]]
  subnet_ids       = module.network.public_subnet_ids
  target_group_arns = [module.loadbalancer.target_group_arn]
  
  max_size              = 5
  min_size              = 2
  desired_capacity      = 3
  cpu_scale_out_threshold = 70
  cpu_scale_in_threshold  = 30
  enable_scaling_policies = true
}
```

### 4. Load Balancer Module (`modules/loadbalancer/`)

Generic module for creating Application Load Balancers.

**Resources:**
- Application Load Balancer
- Target Group with health checks
- Load balancer listener

**Key Features:**
- Configurable load balancer and target group names
- Internal/external load balancer support
- Customizable health check settings
- Flexible port and protocol configuration

**Usage:**
```hcl
module "loadbalancer" {
  source = "./modules/loadbalancer"
  
  name_prefix      = "my-project"
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.public_subnet_ids
  security_group_id = module.security.security_group_ids["alb"]
  
  load_balancer_name = "web-alb"
  target_group_name  = "web-tg"
  internal          = false
  target_port       = 80
  listener_port     = 80
}
```

### 5. Security Groups Module (`modules/security-groups/`)

Generic module for creating security groups with flexible rules.

**Resources:**
- Multiple security groups with custom rules
- Dynamic ingress/egress rule creation

**Key Features:**
- Flexible rule configuration
- Support for CIDR blocks and security group references
- Individual tagging per security group
- Convenience outputs for common security groups

**Usage:**
```hcl
module "security" {
  source = "./modules/security-groups"
  
  name_prefix = "my-project"
  vpc_id      = module.network.vpc_id
  
  security_groups = [
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
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- SSH key pair in AWS
- S3 bucket for Terraform state (optional)

### 1. Clone and Initialize

```bash
git clone <repository-url>
cd fortstack-terrform
terraform init
```

### 2. Configure Variables

Copy the example variables file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
region = "us-west-1"
name_prefix = "my-wordpress"
key_name = "my-ssh-key"
instance_type = "t3.small"
```

### 3. Plan and Apply

```bash
terraform plan
terraform apply
```

### 4. Access Your Application

After deployment, get the load balancer DNS name:

```bash
terraform output load_balancer_dns_name
```

Visit the URL in your browser to see your WordPress site.

## ⚙️ Configuration

### Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region | `us-west-1` |
| `name_prefix` | Prefix for resource names | `wordpress-mysql` |
| `key_name` | SSH key name for instances | `omnia-key` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `instance_type` | EC2 instance type | `t3.small` |
| `max_size` | Maximum ASG instances | `3` |
| `min_size` | Minimum ASG instances | `1` |
| `desired_capacity` | Desired ASG instances | `2` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |

### Subnet Configuration

The `subnets_list` variable allows you to define custom subnets:

```hcl
subnets_list = [
  {
    name              = "public_subnet1"
    cidr              = "10.0.1.0/24"
    type              = "public"
    availability_zone = "us-west-1a"
  },
  {
    name              = "private_subnet1"
    cidr              = "10.0.4.0/24"
    type              = "private"
    availability_zone = "us-west-1a"
  }
]
```

## 📊 Outputs

The infrastructure provides several useful outputs:

- `vpc_id` - VPC ID
- `mysql_private_ip` - MySQL instance private IP
- `wordpress_autoscaling_group_name` - ASG name
- `load_balancer_dns_name` - Load balancer DNS name
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_ids` - List of private subnet IDs

## 🔧 Customization

### Adding New Applications

To add a new application, simply use the generic modules:

```hcl
# New application ASG
module "my_app" {
  source = "./modules/asg"
  
  name_prefix = var.name_prefix
  ami         = "ami-12345678"
  # ... other configuration
}

# New application load balancer
module "my_app_lb" {
  source = "./modules/loadbalancer"
  
  name_prefix = var.name_prefix
  # ... other configuration
}
```

### Modifying Security Groups

Add new security groups by extending the `security_groups` list:

```hcl
security_groups = [
  # ... existing groups
  {
    name        = "api"
    description = "Security group for API servers"
    ingress_rules = [
      {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
]
```

## 🛠️ Backend Configuration

The project uses S3 for state storage with DynamoDB for locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "omnia-fortstack-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

## 🔍 Monitoring and Scaling

### Auto Scaling

The WordPress ASG automatically scales based on CPU utilization:
- **Scale Out**: When CPU > 50% for 2 periods
- **Scale In**: When CPU < 20% for 2 periods
- **Cooldown**: 300 seconds between scaling actions

### Health Checks

- **ASG Health Check**: ELB-based health checks
- **Target Group Health Check**: HTTP health checks on port 80
- **Grace Period**: 300 seconds for instance startup

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources. Make sure to backup any important data first.
---

**Happy Infrastructure Building! 🚀**
