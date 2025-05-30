output "aap_job_template_id" {
  description = "ID of the AAP job template"
  value       = local.template_id
}

output "aap_url" {
  description = "AAP URL (either ALB domain or instance IP)"
  value       = local.aap_url
}
