output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "wp_security_group_id" {
  description = "ID of the WordPress security group"
  value       = aws_security_group.wp_sg.id
}

output "mysql_security_group_id" {
  description = "ID of the MySQL security group"
  value       = aws_security_group.mysql_sg.id
}
