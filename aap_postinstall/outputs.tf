output "aap_job_template_id" {
  description = "ID of the AAP job template"
  value       = data.aap_job_template.vault_config.id
}

output "aap_url" {
  description = "AAP URL (either ALB domain or instance IP)"
  value       = local.aap_url
}


output "aap_job_status" {
  description = "Status of the AAP job"
  value       = aap_job.config_vault_credentials.status
}