variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

<<<<<<< Updated upstream
variable "wordpress_ami" {
  description = "AMI ID for WordPress instances"
  type        = string
  default     = "ami-0424788ce1ae8d5eb"
}

variable "mysql_ami" {
  description = "AMI ID for MySQL instance"
  type        = string
  default     = "ami-0ddac4b9aed8d5d46"
=======
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "wordpress-mysql"
}


variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
  default     = "omnia-key"
}

variable "max_size" {
  description = "Maximum number of WordPress instances"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of WordPress instances"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of WordPress instances"
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
>>>>>>> Stashed changes
}
