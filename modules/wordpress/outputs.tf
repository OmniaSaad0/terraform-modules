output "launch_template_id" {
  description = "ID of the WordPress launch template"
  value       = aws_launch_template.wordpress.id
}

output "launch_template_arn" {
  description = "ARN of the WordPress launch template"
  value       = aws_launch_template.wordpress.arn
}

output "autoscaling_group_name" {
  description = "Name of the WordPress Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress_asg.name
}

output "autoscaling_group_arn" {
  description = "ARN of the WordPress Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress_asg.arn
}

output "scale_out_policy_arn" {
  description = "ARN of the scale out policy"
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "ARN of the scale in policy"
  value       = aws_autoscaling_policy.scale_in.arn
}
