resource "vault_mount" "ssh" {
  path = "ssh"
  type = "ssh"

  namespace = var.namespace
}

resource "vault_ssh_secret_backend_ca" "this" {
  backend              = vault_mount.ssh.path
	generate_signing_key = true

  namespace = var.namespace
}

resource "vault_ssh_secret_backend_role" "this" {
	backend                 = vault_mount.ssh.path
	name                    = var.ssh_role_name
	allow_user_certificates = true
  default_user            = "packer"
  allowed_users           = "*"
  key_type                = "ca"
  ttl                     = "28800"
  max_ttl                 = "28800"
  default_extensions      = {"permit-pty"=""}
  allowed_extensions      = "permit-pty,permit-port-forwarding"

  namespace = var.namespace
}