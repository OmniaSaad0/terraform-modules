output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.main.arn
}

output "availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = aws_instance.main.availability_zone
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.main.instance_state
}
