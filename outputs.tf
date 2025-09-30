output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "mysql_private_ip" {
  description = "Private IP of the MySQL instance"
  value       = aws_instance.mysql.private_ip
}

output "wordpress_autoscaling_group_name" {
  description = "Name of the WordPress Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress_asg.name
}

output "wordpress_launch_template_id" {
  description = "ID of the WordPress Launch Template"
  value       = aws_launch_template.wordpress.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.network.private_subnet_id
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.wordpress_alb.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.wordpress_alb.zone_id
}
