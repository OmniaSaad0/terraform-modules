output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.enable_alb_sg ? aws_security_group.alb_sg[0].id : null
}

output "wp_security_group_id" {
  description = "ID of the WordPress security group"
  value       = var.enable_wp_sg ? aws_security_group.wp_sg[0].id : null
}

output "mysql_security_group_id" {
  description = "ID of the MySQL security group"
  value       = var.enable_mysql_sg ? aws_security_group.mysql_sg[0].id : null
}
