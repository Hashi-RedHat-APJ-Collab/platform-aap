locals {
    # ternary operator to set the AAP URL if  var.create_alb ? 1 : 0
  aap_url = var.create_alb ? "https://${aws_route53_record.aap_alb_dns[0].fqdn}" : "http://${aws_instance.aap_instance.public_ip}"
  response_body = jsondecode(data.http.aap_job_template.response_body)
  template_id = local.response_body.results[0].id

  ssh-unsigned-public-key = tls_private_key.ssh-key.public_key_openssh
  ssh-unsigned-private-key = tls_private_key.ssh-key.private_key_openssh
}

resource "tls_private_key" "ssh-key" {
  algorithm = "ED25519"
}


#urlencode the job_template_name
data "http" "aap_job_template" {
  depends_on = [terraform_data.wait_for_healthy_target]
  url = "${local.aap_url}/api/controller/v2/job_templates/?name=${urlencode(var.job_template_name)}"
  insecure=true

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
  job_template_id = local.template_id
  extra_vars      = jsonencode({
    "tenant" : var.tenant, # aligned to Vault
    "organization_name" : "Default",
    "aap_url" : local.aap_url,
    "role_id" : "test_role_id", # to come from Vault
    "secret_id" : "test_secret_id", # to come from Vault
    "machine_user" : "${var.machine_user}",
    "ssh_public_key": local.ssh-unsigned-public-key,
    "ssh_private_key": local.ssh-unsigned-private-key,
    "role" : "aap_${var.tenant}", # to come from Vault
    "secret_path" : "ssh_${var.tenant}", # to come from Vault
  })
}

output "aap_job_template_id" {
  value = local.template_id
}

output "ssh-unsigned-public-key" {
  value = nonsensitive(local.ssh-unsigned-public-key)
}

output "ssh-unsigned-private-key" {
  value = nonsensitive(local.ssh-unsigned-private-key)
}
