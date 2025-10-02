output "security_group_ids" {
  description = "Map of security group names to their IDs"
  value = {
    for name, sg in aws_security_group.main : name => sg.id
  }
}

output "security_group_arns" {
  description = "Map of security group names to their ARNs"
  value = {
    for name, sg in aws_security_group.main : name => sg.arn
  }
}

# Convenience outputs for common security groups
output "alb_security_group_id" {
  description = "ID of the ALB security group (if it exists)"
  value       = try(aws_security_group.main["alb"].id, null)
}

output "web_security_group_id" {
  description = "ID of the web security group (if it exists)"
  value       = try(aws_security_group.main["web"].id, null)
}

output "database_security_group_id" {
  description = "ID of the database security group (if it exists)"
  value       = try(aws_security_group.main["database"].id, null)
}