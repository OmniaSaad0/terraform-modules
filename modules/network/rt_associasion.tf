# Dynamic route table associations for all subnets
resource "aws_route_table_association" "subnet_associations" {
  for_each = aws_subnet.main
  
  subnet_id      = each.value.id
  route_table_id = each.value.tags.Type == "public" ? aws_route_table.public_route_table.id : aws_route_table.private_route_table.id
}
