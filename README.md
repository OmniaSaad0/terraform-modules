# WordPress & MySQL Infrastructure

This Terraform configuration creates a modular, scalable WordPress infrastructure with MySQL database, load balancer, and auto-scaling capabilities.

## Architecture

- **Network Module**: VPC, subnets, internet gateway, NAT gateway, and routing
- **Security Module**: Security groups for ALB, WordPress, and MySQL
- **Load Balancer Module**: Application Load Balancer with target group
- **MySQL Module**: EC2 instance with MySQL server and database configuration
- **WordPress Module**: Auto Scaling Group with launch template and scaling policies

## Modules

### Network Module (`modules/network/`)
- VPC with DNS support
- Public subnets in multiple AZs
- Private subnet for MySQL
- Internet Gateway and NAT Gateway
- Route tables and associations

### Security Module (`modules/security/`)
- ALB Security Group (HTTP access)
- WordPress Security Group (HTTP + SSH access)
- MySQL Security Group (MySQL + SSH access)

### Load Balancer Module (`modules/loadbalancer/`)
- Application Load Balancer
- Target Group with health checks
- HTTP listener

### MySQL Module (`modules/mysql/`)
- EC2 instance with MySQL server
- Automatic database and user creation
- Network configuration for remote access

### WordPress Module (`modules/wordpress/`)
- Launch Template with user data
- Auto Scaling Group
- CPU-based scaling policies
- CloudWatch alarms

## Usage

### Basic Usage

```hcl
module "wordpress_infrastructure" {
  source = "./path/to/this/repository"
  
  name_prefix    = "my-wordpress"
  region         = "us-west-1"
  wordpress_ami  = "ami-0424788ce1ae8d5eb"
  mysql_ami      = "ami-0ddac4b9aed8d5d46"
  key_name       = "my-key"
}
```

### Advanced Usage

```hcl
module "wordpress_infrastructure" {
  source = "./path/to/this/repository"
  
  name_prefix              = "production-wordpress"
  region                   = "us-west-1"
  wordpress_ami            = "ami-0424788ce1ae8d5eb"
  mysql_ami                = "ami-0ddac4b9aed8d5d46"
  key_name                 = "production-key"
  instance_type            = "t3.medium"
  max_size                 = 5
  min_size                 = 2
  desired_capacity         = 3
  cpu_scale_out_threshold  = 70
  cpu_scale_in_threshold   = 30
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for resource names | `string` | `"wordpress-mysql"` |
| `region` | AWS region | `string` | `"us-west-1"` |
| `wordpress_ami` | AMI ID for WordPress instances | `string` | `"ami-0424788ce1ae8d5eb"` |
| `mysql_ami` | AMI ID for MySQL instance | `string` | `"ami-0ddac4b9aed8d5d46"` |
| `instance_type` | Instance type for EC2 instances | `string` | `"t3.small"` |
| `key_name` | SSH key name for EC2 instances | `string` | `"omnia-key"` |
| `max_size` | Maximum number of WordPress instances | `number` | `3` |
| `min_size` | Minimum number of WordPress instances | `number` | `1` |
| `desired_capacity` | Desired number of WordPress instances | `number` | `2` |
| `cpu_scale_out_threshold` | CPU threshold for scaling out | `number` | `50` |
| `cpu_scale_in_threshold` | CPU threshold for scaling in | `number` | `20` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `mysql_private_ip` | Private IP of the MySQL instance |
| `mysql_instance_id` | ID of the MySQL instance |
| `wordpress_autoscaling_group_name` | Name of the WordPress Auto Scaling Group |
| `wordpress_launch_template_id` | ID of the WordPress Launch Template |
| `public_subnet_ids` | IDs of the public subnets |
| `private_subnet_id` | ID of the private subnet |
| `load_balancer_dns_name` | DNS name of the load balancer |
| `load_balancer_zone_id` | Zone ID of the load balancer |
| `target_group_arn` | ARN of the target group |

## Features

- ✅ **High Availability**: Multi-AZ deployment
- ✅ **Auto Scaling**: CPU-based scaling policies
- ✅ **Load Balancing**: Application Load Balancer
- ✅ **Security**: Proper security groups and network isolation
- ✅ **Monitoring**: CloudWatch alarms and health checks
- ✅ **Modular**: Reusable modules for different projects
- ✅ **Configurable**: Extensive customization options

## Prerequisites

- AWS CLI configured
- Terraform installed
- SSH key pair in AWS
- Custom WordPress and MySQL AMIs

## Deployment

1. Clone this repository
2. Update variables in `variables.tf` or create `terraform.tfvars`
3. Initialize Terraform: `terraform init`
4. Plan deployment: `terraform plan`
5. Apply configuration: `terraform apply`

## Access

- **WordPress**: Access via load balancer DNS name
- **MySQL**: SSH to private instance using the provided key
- **SSH Access**: Use the specified key name for all instances

## Customization

Each module can be customized by modifying the respective `variables.tf` file or by passing different values when calling the modules.

## Backend

This configuration uses S3 backend for state storage with DynamoDB locking. Configure the backend in `backend.tf` before deployment.
