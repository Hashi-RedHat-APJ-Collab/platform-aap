locals {
    # ternary operator to set the AAP URL if ALB is created
  aap_url = var.create_alb ? "https://${var.domain_name}" : "http://${var.aap_instance_public_ip}"
  response_body = jsondecode(data.http.aap_job_template.response_body)
  template_id = local.response_body.results[0].id
}



# urlencode the job_template_name
data "http" "aap_job_template" {
  depends_on = [var.wait_for_healthy_target]
  url = "${local.aap_url}/api/controller/v2/job_templates/?name=${urlencode(var.job_template_name)}"
  insecure = true

  request_headers = {
    Accept        = "application/json"
    Authorization = "Basic ${base64encode("${var.aap_username}:${var.aap_password}")}"
  }
}

# tenant: demo
# organization_name: Default
# vault_url: https://tf-aap-public-vault-76d1afab.7739a0fc.z1.hashicorp.cloud:8200
# vault_namespace: admin/hashi-redhat
# aap_url: https://aap.simon-lynch.sbx.hashidemos.io
# state: present
# secret_id: $encrypted$
# role_id: $encrypted$

resource "aap_job" "config_vault_credentials" {
  depends_on = [
    data.http.aap_job_template,
    var.wait_for_healthy_target
  ]
            
  job_template_id = local.template_id
  extra_vars      = jsonencode({
    "tenant" : var.tenant, # aligned to Vault
    "organization_name" : "Default",
    "aap_url" : local.aap_url,
    "role_id" : var.vault_approle_role_id, # from Vault
    "secret_id" : var.vault_approle_secret_id, # from Vault
    "machine_user" : "${var.machine_user}",
    "ssh_public_key": var.unsigned_ssh_public_key,
    "ssh_private_key": var.unsigned_ssh_private_key,
    "ssh_vault_role" : "ssh_${var.tenant}", # to come from Vault
    "secret_path" : "ssh_${var.tenant}", # to come from Vault
  })

  triggers = var.job_triggers
}
