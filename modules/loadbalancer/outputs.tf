output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.alb.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.tg.arn
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.tg.id
}

output "listener_arn" {
  description = "ARN of the load balancer listener"
  value       = aws_lb_listener.listener.arn
}
