# Output values

output "public_ip" {
  value = aws_instance.aap_instance.public_ip
}

output "public_fqdn" {
  value = aws_instance.aap_instance.public_dns
}

output "instance_id" {
  value = aws_instance.aap_instance.id
}

# output "efs_dns_name" {
#   value = aws_efs_file_system.efs.dns_name
# }

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = var.create_alb ? aws_lb.aap_alb[0].dns_name : null
}

output "route53_record_name" {
  description = "Route53 record name for the ALB"
  value       = var.create_alb ? "https://${aws_route53_record.aap_alb_dns[0].fqdn}" : null
}
