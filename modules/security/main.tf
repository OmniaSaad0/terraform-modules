# Security Group for Load Balancer
resource "aws_security_group" "alb_sg" {
  count  = var.enable_alb_sg ? 1 : 0
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_allowed_cidrs
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.name_prefix}-ALB-Security-Group"
  }, var.additional_tags)
}

# Security Group for WordPress
resource "aws_security_group" "wp_sg" {
  count  = var.enable_wp_sg ? 1 : 0
  name   = "${var.name_prefix}-wp-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.wp_allowed_cidrs
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = var.wp_allowed_cidrs
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.name_prefix}-WordPress-Security-Group"
  }, var.additional_tags)
}

# Security Group for MySQL
resource "aws_security_group" "mysql_sg" {
  count  = var.enable_mysql_sg ? 1 : 0
  name   = "${var.name_prefix}-mysql-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.mysql_allowed_cidrs
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = var.wp_security_group_ids
    content {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.name_prefix}-MySQL-Security-Group"
  }, var.additional_tags)
}
