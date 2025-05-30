# Output values

output "public_ip" {
  description = "Public IP address of the AAP instance"
  value       = module.aap_instance.public_ip
}

output "public_fqdn" {
  description = "Public FQDN of the AAP instance"
  value       = module.aap_instance.public_fqdn
}

output "instance_id" {
  description = "ID of the AAP instance"
  value       = module.aap_instance.instance_id
}

# output "efs_dns_name" {
#   value = aws_efs_file_system.efs.dns_name
# }

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.aap_instance.alb_dns_name
}

output "route53_record_name" {
  description = "Route53 record name for the ALB"
  value       = module.aap_instance.route53_record_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.aap_instance.vpc_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.aap_instance.security_group_id
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = module.aap_instance.key_pair_name
}

output "private_key_pem" {
  description = "Private key in PEM format"
  value       = module.aap_instance.private_key_pem
  sensitive   = true
}

# # AAP Configuration outputs
# output "aap_job_template_id" {
#   description = "ID of the AAP job template"
#   value       = module.aap_config.aap_job_template_id
# }

# output "ssh_unsigned_public_key" {
#   description = "SSH unsigned public key"
#   value       = module.aap_config.ssh_unsigned_public_key
# }

# output "ssh_unsigned_private_key" {
#   description = "SSH unsigned private key"
#   value       = module.aap_config.ssh_unsigned_private_key
#   sensitive   = true
# }

# output "aap_url" {
#   description = "AAP URL (either ALB domain or instance IP)"
#   value       = module.aap_config.aap_url
# }

# output "aap_job_id" {
#   description = "ID of the executed AAP job"
#   value       = module.aap_config.aap_job_id
# }
