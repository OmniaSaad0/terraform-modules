# Generic Security Groups
resource "aws_security_group" "main" {
  for_each = { for sg in var.security_groups : sg.name => sg }
  
  name        = "${var.name_prefix}-${each.value.name}"
  description = each.value.description
  vpc_id      = var.vpc_id

  # Ingress rules
  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      security_groups  = ingress.value.security_groups
      description      = ingress.value.description
    }
  }

  # Egress rules
  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      security_groups  = egress.value.security_groups
      description      = egress.value.description
    }
  }

  tags = merge({
    Name = "${var.name_prefix}-${title(each.value.name)}"
  }, each.value.tags, var.additional_tags)
}