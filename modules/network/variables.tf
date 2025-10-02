variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
}

variable "region" {
  type = string
  description = "AWS region to deploy the VPC"
}


variable "project_name" {
  type        = string
  description = "Name of the project for resource naming"
  default     = "wordpress-mysql"
}

variable "subnets_list" {
  type = list(object({
    name             = string
    cidr             = string
    availability_zone = string
    type             = string  # "public" or "private"
  }))
  description = "List of subnets to create with their configuration"
  
}

