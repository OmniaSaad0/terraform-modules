output "my_vpc" {
  value = aws_vpc.my-vpc.id
}

output "public_subnet1_id" {
  value = aws_subnet.public_subnet1.id
}

output "public_subnet2_id" {
  value = aws_subnet.public_subnet2.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "vpc_id" {
  value = aws_vpc.my-vpc.id
}