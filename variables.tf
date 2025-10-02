variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

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
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "wordpress-mysql"
} 

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets_list" {
  type = list(object({
    name              = string
    cidr              = string
    type              = string
    availability_zone = string
  }))
  description = "List of subnets to create with their configuration"
  default = [
    {
      name             = "public_subnet1"
      cidr             = "10.0.1.0/24"
      availability_zone = "us-west-1a"
      type             = "public"
    },
    {
      name             = "public_subnet2"
      cidr             = "10.0.2.0/24"
      availability_zone = "us-west-1c"
      type             = "public"
    },
    {
      name             = "private_subnet1"
      cidr             = "10.0.4.0/24"
      availability_zone = "us-west-1a"
      type             = "private"
    }
  ]
}