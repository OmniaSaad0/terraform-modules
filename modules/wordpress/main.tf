# WordPress Launch Template
resource "aws_launch_template" "wordpress" {
  name_prefix   = "${var.name_prefix}-wp-"
  image_id      = var.wordpress_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update WordPress configuration with MySQL details
              sed -i "s/define( 'DB_HOST', 'REPLACEME' );/define( 'DB_HOST', '${var.mysql_private_ip}' );/" /var/www/html/wp-config.php
              sed -i "s/define( 'DB_NAME', 'REPLACEME' );/define( 'DB_NAME', '${var.database_name}' );/" /var/www/html/wp-config.php
              sed -i "s/define( 'DB_USER', 'REPLACEME' );/define( 'DB_USER', '${var.database_user}' );/" /var/www/html/wp-config.php
              sed -i "s/define( 'DB_PASSWORD', 'REPLACEME' );/define( 'DB_PASSWORD', '${var.database_password}' );/" /var/www/html/wp-config.php
              
              # Start Apache
              systemctl start apache2
              systemctl enable apache2
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name = "${var.name_prefix}-WordPress-Instance"
    }, var.additional_tags)
  }

  tags = merge({
    Name = "${var.name_prefix}-WordPress-Template"
  }, var.additional_tags)
}

# Auto Scaling Group
resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "${var.name_prefix}-wordpress-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-WordPress-ASG"
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

# CloudWatch Alarm for Scale Out
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_scale_out_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }
}

# CloudWatch Alarm for Scale In
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_scale_in_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }
}

# Auto Scaling Policy - Scale Out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name_prefix}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
}

# Auto Scaling Policy - Scale In
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name_prefix}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
}
