output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "my_vpc" {
  description = "ID of the VPC (alias for vpc_id)"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [for subnet in aws_subnet.main : subnet.id if subnet.tags.Type == "public"]
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = [for subnet in aws_subnet.main : subnet.id if subnet.tags.Type == "private"]
}


output "all_subnet_ids" {
  description = "List of IDs of all subnets"
  value       = [for subnet in aws_subnet.main : subnet.id]
}

output "subnet_details" {
  description = "Map of subnet details by name"
  value = {
    for name, subnet in aws_subnet.main : name => {
      id               = subnet.id
      cidr_block       = subnet.cidr_block
      availability_zone = subnet.availability_zone
      type             = subnet.tags.Type
    }
  }
}