resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = [for subnet in aws_subnet.main : subnet.id if subnet.tags.Type == "public"][0]
  depends_on    = [aws_internet_gateway.my_igw]

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
}