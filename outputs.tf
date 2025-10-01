output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "mysql_private_ip" {
  description = "Private IP of the MySQL instance"
  value       = module.mysql.private_ip
}

output "mysql_instance_id" {
  description = "ID of the MySQL instance"
  value       = module.mysql.instance_id
}

output "wordpress_autoscaling_group_name" {
  description = "Name of the WordPress Auto Scaling Group"
  value       = module.wordpress.autoscaling_group_name
}

output "wordpress_launch_template_id" {
  description = "ID of the WordPress Launch Template"
  value       = module.wordpress.launch_template_id
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
  value       = module.loadbalancer.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.loadbalancer.load_balancer_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.loadbalancer.target_group_arn
}
