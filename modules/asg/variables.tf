variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami" {
  description = "AMI ID for the instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the instances"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for the instances"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for the instances"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to attach to the ASG"
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
  description = "Name for the instances"
  type        = string
  default     = "asg-instance"
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "Type of health check for the ASG"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Grace period for health checks"
  type        = number
  default     = 300
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

variable "enable_scaling_policies" {
  description = "Whether to enable scaling policies"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
