



resource "vault_ssh_secret_backend_role" "this" {
	backend                 = "ssh"
	name                    = var.tenant
	allow_user_certificates = true
  #default_user            = "ec2-user"
  allowed_users           = "*"
  key_type                = "ca"
  ttl                     = "28800"
  max_ttl                 = "28800"
  default_extensions      = {"permit-pty"=""}
  allowed_extensions      = "permit-pty,permit-port-forwarding"

}