output "public_ip" {
  description = "Public IP address of the AAP instance"
  value       = aws_instance.aap_instance.public_ip
}

output "public_fqdn" {
  description = "Public FQDN of the AAP instance"
  value       = aws_instance.aap_instance.public_dns
}

output "instance_id" {
  description = "ID of the AAP instance"
  value       = aws_instance.aap_instance.id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = var.create_alb ? aws_lb.aap_alb[0].dns_name : null
}

output "route53_record_name" {
  description = "Route53 record name for the ALB"
  value       = var.create_alb ? "https://${aws_route53_record.aap_alb_dns[0].fqdn}" : null
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.aap_vpc.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.aap_security_group.id
}

output "subnet_az1_id" {
  description = "ID of the public subnet in AZ1"
  value       = aws_subnet.aap_public_subnet_az1.id
}

output "subnet_az2_id" {
  description = "ID of the public subnet in AZ2"
  value       = aws_subnet.aap_public_subnet_az2.id
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = module.key_pair.key_pair_name
}

output "private_key_pem" {
  description = "Private key in PEM format"
  value       = module.key_pair.private_key_pem
  sensitive   = true
}

output "wait_for_healthy_target" {
  description = "Dependency object to wait for healthy target"
  value       = var.create_alb ? terraform_data.wait_for_healthy_target[0] : null
} 