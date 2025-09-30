variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "wordpress_ami" {
  description = "AMI ID for WordPress instances"
  type        = string
  default     = "ami-0424788ce1ae8d5eb"
}

variable "mysql_ami" {
  description = "AMI ID for MySQL instance"
  type        = string
  default     = "ami-0ddac4b9aed8d5d46"
}
