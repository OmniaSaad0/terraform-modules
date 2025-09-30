# Security Groups
resource "aws_security_group" "mysql_sg" {
  name   = "mysql-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wp_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL-Security-Group"
  }
}

resource "aws_security_group" "wp_sg" {
  name   = "wordpress-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WordPress-Security-Group"
  }
}

# MySQL EC2 Instance
resource "aws_instance" "mysql" {
  ami                    = var.mysql_ami
  instance_type          = "t3.small"
  key_name               = "omnia-key"
  subnet_id              = module.network.private_subnet_id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y mysql-server
              
              # Start MySQL service
             sudo systemctl start mysql
              sudo systemctl enable mysql
              
              # Wait for MySQL to be ready
              sleep 30
              
              # Configure MySQL to accept connections from any host first
              sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
              
              # Restart MySQL to apply bind-address change
              sudo systemctl restart mysql
              sleep 10
              
              # Create MySQL configuration file for setup
              sudo cat > /tmp/mysql_setup.sql << 'EOL'
              CREATE DATABASE IF NOT EXISTS wordpress;
              DROP USER IF EXISTS 'admin'@'%';
              CREATE USER 'admin'@'%' IDENTIFIED BY 'Pass1234';
              GRANT ALL PRIVILEGES ON wordpress.* TO 'admin'@'%';
              CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Pass1234';
              GRANT ALL PRIVILEGES ON wordpress.* TO 'admin'@'localhost';
              FLUSH PRIVILEGES;
              EOL
              
              # Execute MySQL setup with error handling
              sudo mysql < /tmp/mysql_setup.sql 2>&1 | tee /tmp/mysql_setup.log
              
              # Verify the setup
              sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User='admin';" 2>&1 | tee /tmp/mysql_users.log
              sudo mysql -e "SHOW DATABASES;" 2>&1 | tee /tmp/mysql_databases.log
              
              # Final restart to ensure everything is applied
              sudo systemctl restart mysql
              
              # Clean up
              sudo rm /tmp/mysql_setup.sql
              EOF
  )

  tags = {
    Name = "MySQL-Server"
  }
}

# WordPress Launch Template
resource "aws_launch_template" "wordpress" {
  name_prefix   = "wordpress-"
  image_id      = var.wordpress_ami
  instance_type = "t3.small"
  key_name      = "omnia-key"

  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update WordPress configuration with MySQL details
              sed -i "s/DB_HOST.*/DB_HOST', '${aws_instance.mysql.private_ip}');/" /var/www/html/wp-config.php
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

# Application Load Balancer
resource "aws_lb" "wordpress_alb" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.network.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "WordPress-ALB"
  }
}

# Target Group for WordPress
resource "aws_lb_target_group" "wordpress_tg" {
  name     = "wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "WordPress-Target-Group"
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "wordpress_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "alb_sg" {
  name   = "wordpress-alb-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WordPress-ALB-Security-Group"
  }
}

# Auto Scaling Group for WordPress
resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "wordpress-asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = module.network.public_subnet_ids
  target_group_arns         = [aws_lb_target_group.wordpress_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WordPress-EC2"
    propagate_at_launch = true
  }
}

# CloudWatch CPU Metric Alarm for Scale Out
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "wordpress-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }
}

# CloudWatch CPU Metric Alarm for Scale In
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "wordpress-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }
}

# Auto Scaling Policy for Scale Out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "wordpress-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
}

# Auto Scaling Policy for Scale In
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "wordpress-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
}
