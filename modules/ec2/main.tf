# Generic EC2 Instance
resource "aws_instance" "main" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  # User data is optional - only set if provided
  user_data = var.user_data != null ? base64encode(var.user_data) : (
    var.user_data_base64 != null ? var.user_data_base64 : null
  )

  tags = merge({
    Name = "${var.name_prefix}-${var.instance_name}"
  }, var.additional_tags)
}
