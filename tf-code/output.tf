output "alb_dns_name" {
  value = aws_alb.main.dns_name
  description = "Application Load Balancer name:"
}

output "rds_dns_name" {
  value = aws_db_instance.mysql.address
  description = "RDS DNS name. used to connect to database:"
}

output "aws_ecr_repository_url" {
    value = aws_ecr_repository.main.repository_url
    description = "ECR repository URL:"
}

output "instance_ip_addr" {
  value = aws_eip.bastion_eip.public_ip
  description = "Bastion host public IP:"
}
