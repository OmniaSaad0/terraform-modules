output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "ARN of the Launch Template"
  value       = aws_launch_template.main.arn
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.main.latest_version
}

output "scale_out_policy_arn" {
  description = "ARN of the scale out policy"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_out[0].arn : null
}

output "scale_in_policy_arn" {
  description = "ARN of the scale in policy"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_in[0].arn : null
}

output "cpu_high_alarm_arn" {
  description = "ARN of the CPU high alarm"
  value       = var.enable_scaling_policies ? aws_cloudwatch_metric_alarm.cpu_high[0].arn : null
}

output "cpu_low_alarm_arn" {
  description = "ARN of the CPU low alarm"
  value       = var.enable_scaling_policies ? aws_cloudwatch_metric_alarm.cpu_low[0].arn : null
}
