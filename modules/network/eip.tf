resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.my_igw]

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}