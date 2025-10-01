variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "enable_alb_sg" {
  description = "Whether to create ALB security group"
  type        = bool
  default     = true
}

variable "enable_wp_sg" {
  description = "Whether to create WordPress security group"
  type        = bool
  default     = true
}

variable "enable_mysql_sg" {
  description = "Whether to create MySQL security group"
  type        = bool
  default     = true
}

variable "alb_allowed_cidrs" {
  description = "CIDR blocks allowed to access ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "wp_allowed_cidrs" {
  description = "CIDR blocks allowed to access WordPress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "mysql_allowed_cidrs" {
  description = "CIDR blocks allowed to access MySQL"
  type        = list(string)
  default     = []
}

variable "wp_security_group_ids" {
  description = "Security group IDs allowed to access MySQL"
  type        = list(string)
  default     = []
}

variable "additional_tags" {
  description = "Additional tags to apply to security groups"
  type        = map(string)
  default     = {}
}
