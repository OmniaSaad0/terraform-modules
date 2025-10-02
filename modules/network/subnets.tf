
resource "aws_subnet" "main" {
  for_each = { for subnet in var.subnets_list : subnet.name => subnet }
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.type == "public" ? true : false
  
  tags = {
    Name = each.value.name
    Type = each.value.type
  }
}





