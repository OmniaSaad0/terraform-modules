# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-${var.load_balancer_name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge({
    Name = "${var.name_prefix}-${title(var.load_balancer_name)}"
  }, var.additional_tags)
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.name_prefix}-${var.target_group_name}"
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.target_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge({
    Name = "${var.name_prefix}-${title(var.target_group_name)}"
  }, var.additional_tags)
}

# Load Balancer Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
