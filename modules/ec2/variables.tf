variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the instance"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for the instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for the instance"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64 encoded user data script"
  type        = string
  default     = null
}

variable "instance_name" {
  description = "Name for the instance"
  type        = string
  default     = "ec2-instance"
}

variable "additional_tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
}
