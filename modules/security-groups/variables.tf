variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "security_groups" {
  description = "List of security groups to create"
  type = list(object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), [])
      security_groups = optional(list(string), [])
      description = optional(string, "")
    }))
    egress_rules = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      security_groups = optional(list(string), [])
      description = optional(string, "")
    })), [])
    tags = optional(map(string), {})
  }))
  default = []
}

variable "additional_tags" {
  description = "Additional tags to apply to all security groups"
  type        = map(string)
  default     = {}
}