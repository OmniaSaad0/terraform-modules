variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "mysql_ami" {
  description = "AMI ID for MySQL instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for MySQL instance"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for MySQL instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for MySQL instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for MySQL instance"
  type        = string
}
