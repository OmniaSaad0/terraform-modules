# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  # User data is optional - only set if provided
  user_data = var.user_data != null ? base64encode(var.user_data) : (
    var.user_data_base64 != null ? var.user_data_base64 : null
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name = "${var.name_prefix}-${var.instance_name}"
    }, var.additional_tags)
  }

  tags = merge({
    Name = "${var.name_prefix}-launch-template"
  }, var.additional_tags)
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.name_prefix}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.additional_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# CloudWatch Metric Alarm for Scale Out
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.enable_scaling_policies ? 1 : 0

  alarm_name          = "${var.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_scale_out_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

# CloudWatch Metric Alarm for Scale In
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count = var.enable_scaling_policies ? 1 : 0

  alarm_name          = "${var.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_scale_in_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_in[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

# Auto Scaling Policy for Scale Out
resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_scaling_policies ? 1 : 0

  name                   = "${var.name_prefix}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Auto Scaling Policy for Scale In
resource "aws_autoscaling_policy" "scale_in" {
  count = var.enable_scaling_policies ? 1 : 0

  name                   = "${var.name_prefix}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}
