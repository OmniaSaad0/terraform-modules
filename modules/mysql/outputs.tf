output "instance_id" {
  description = "ID of the MySQL instance"
  value       = aws_instance.mysql.id
}

output "private_ip" {
  description = "Private IP of the MySQL instance"
  value       = aws_instance.mysql.private_ip
}

output "public_ip" {
  description = "Public IP of the MySQL instance"
  value       = aws_instance.mysql.public_ip
}

output "instance_arn" {
  description = "ARN of the MySQL instance"
  value       = aws_instance.mysql.arn
}

output "availability_zone" {
  description = "Availability zone of the MySQL instance"
  value       = aws_instance.mysql.availability_zone
}
