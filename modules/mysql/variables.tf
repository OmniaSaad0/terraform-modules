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

variable "security_group_ids" {
  description = "Security group IDs for MySQL instance"
  type        = list(string)
  default     = []
}

variable "enable_user_data" {
  description = "Whether to enable MySQL user data configuration"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "wordpress"
}

variable "database_user" {
  description = "Database user to create"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Password for the database user"
  type        = string
  default     = "Pass1234"
  sensitive   = true
}

variable "custom_user_data" {
  description = "Custom user data script (overrides default if provided)"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
}
