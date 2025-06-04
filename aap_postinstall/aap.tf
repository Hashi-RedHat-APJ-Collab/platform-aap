locals {
    # ternary operator to set the AAP URL if ALB is created
  aap_url = var.create_alb ? "https://${var.domain_name}" : "http://${var.aap_instance_public_ip}"

}

data "aap_job_template" "vault_config" {
  depends_on = [var.wait_for_healthy_target]
  name = "Hashicorp Vault demo setup" #var.job_template_name - hard coded due to provider bug see: https://github.com/ansible/terraform-provider-aap/issues/75
  organization_name = "Default"
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
  job_template_id = data.aap_job_template.vault_config.id
  extra_vars      = jsonencode({
    "tenant" : var.tenant, # aligned to Vault
    "organization_name" : "Default",
    "aap_url" : local.aap_url,
    "role_id" : var.vault_approle_role_id, # from Vault
    "secret_id" : var.vault_approle_secret_id, # from Vault
    "machine_user" : "${var.machine_user}",
    "ssh_public_key": var.unsigned_ssh_public_key,
    "ssh_private_key": var.unsigned_ssh_private_key,
    "ssh_vault_role" : "${var.tenant}", # to come from Vault
    "secret_path" : "ssh", # to come from Vault
  })

  triggers = var.job_triggers
}
