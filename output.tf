output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.ubuntu_server.public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "private_key_pem" {
  description = "Private key to SSH into EC2"
  value       = tls_private_key.example.private_key_pem
  sensitive   = true
}
