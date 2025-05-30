output "aap_job_template_id" {
  description = "ID of the AAP job template"
  value       = local.template_id
}

output "ssh_unsigned_public_key" {
  description = "SSH unsigned public key"
  value       = nonsensitive(local.ssh-unsigned-public-key)
}

output "ssh_unsigned_private_key" {
  description = "SSH unsigned private key"
  value       = nonsensitive(local.ssh-unsigned-private-key)
}

output "aap_url" {
  description = "AAP URL (either ALB domain or instance IP)"
  value       = local.aap_url
}
