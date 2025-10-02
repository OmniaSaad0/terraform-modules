
data "aws_ami" "wordpress" {
  most_recent = true
  owners      = ["self"]  

  filter {
    name   = "name"
    values = ["wordpress-ami"]  
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "wordpress_fallback" {
  filter {
    name   = "image-id"
    values = ["ami-0424788ce1ae8d5eb"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

