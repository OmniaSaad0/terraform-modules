variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "wordpress_ami" {
  description = "AMI ID for WordPress instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for WordPress instances"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for WordPress instances"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for WordPress instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for WordPress instances"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs for the load balancer"
  type        = list(string)
}

variable "mysql_private_ip" {
  description = "Private IP of the MySQL instance"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "wordpress"
}

variable "database_user" {
  description = "Database user"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Database password"
  type        = string
  default     = "Pass1234"
  sensitive   = true
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

variable "cpu_scale_out_threshold" {
  description = "CPU threshold for scaling out"
  type        = number
  default     = 50
}

variable "cpu_scale_in_threshold" {
  description = "CPU threshold for scaling in"
  type        = number
  default     = 20
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
