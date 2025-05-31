module "aap_instance" {
  source = "./aap_instance"

  # Required variables
  ami_id            = var.ami_id
  acme_email        = var.acme_email
  domain_name       = var.domain_name
  route53_zone_name = var.route53_zone_name

  # Optional variables
  aws_region                = var.aws_region
  create_alb                = var.create_alb
  subject_alternative_names = var.subject_alternative_names
}

module "vault_ssh" {
  source = "./vault_ssh"

  # Required variables
  namespace          = var.vault_namespace
  aap_admin_password = var.aap_password

  # Optional variables
  auth_backend_approle_path = var.auth_backend_approle_path
  ssh_role_name             = var.tenant
  tenant                    = var.tenant
  approle_mount_accessor    = var.approle_mount_accessor
}

module "aap_postinstall" {
  source = "./aap_postinstall"
  depends_on = [ module.aap_instance, module.vault_ssh ] 

  # Required variables
  domain_name              = var.domain_name
  aap_instance_public_ip   = module.aap_instance.public_ip
  aap_username             = var.aap_username
  aap_password             = var.aap_password
  vault_approle_role_id    = module.vault_ssh.approle_role_id
  vault_approle_secret_id  = module.vault_ssh.approle_secret_id
  unsigned_ssh_public_key  = module.vault_ssh.unsigned_ssh_public_key
  unsigned_ssh_private_key = module.vault_ssh.unsigned_ssh_private_key

  # Optional variables
  create_alb              = var.create_alb
  job_template_name       = var.job_template_name
  tenant                  = var.tenant
  machine_user            = var.machine_user
  wait_for_healthy_target = module.aap_instance.wait_for_healthy_target
  job_triggers            = var.job_triggers
} 


locals {
    # ternary operator to set the AAP URL if ALB is created
  aap_url = var.create_alb ? "https://${var.domain_name}" : "http://${var.aap_instance_public_ip}"
}