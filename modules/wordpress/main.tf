# WordPress Launch Template
resource "aws_launch_template" "wordpress" {
  name_prefix   = "wordpress-"
  image_id      = var.wordpress_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update WordPress configuration with MySQL details
              sed -i "s/DB_HOST.*/DB_HOST', '${var.mysql_private_ip}');/" /var/www/html/wp-config.php
              sed -i "s/DB_NAME.*/DB_NAME', 'wordpress');/" /var/www/html/wp-config.php
              sed -i "s/DB_USER.*/DB_USER', 'admin');/" /var/www/html/wp-config.php
              sed -i "s/DB_PASSWORD.*/DB_PASSWORD', 'Pass1234');/" /var/www/html/wp-config.php
              
              # Start Apache
              systemctl start apache2
              systemctl enable apache2
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Role = "WordPress"
    }
  }
}

# Auto Scaling Group for WordPress
resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "${var.name_prefix}-wordpress-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-WordPress-EC2"
    propagate_at_launch = true
  }
}

# CloudWatch CPU Metric Alarm for Scale Out
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-wordpress-cpu-high"
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

# CloudWatch CPU Metric Alarm for Scale In
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.name_prefix}-wordpress-cpu-low"
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

# Auto Scaling Policy for Scale Out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name_prefix}-wordpress-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
}

# Auto Scaling Policy for Scale In
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name_prefix}-wordpress-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
}
