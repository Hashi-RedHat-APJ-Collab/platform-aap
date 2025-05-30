output "approle_role_id" {
  value = vault_approle_auth_backend_role.this.role_id
}

output "approle_secret_id" {
  value = vault_approle_auth_backend_role_secret_id.this.secret_id
}

output "unsigned_ssh_public_key" {
  value = tls_private_key.ssh-key.public_key_openssh
}

output "unsigned_ssh_private_key" {
  value = tls_private_key.ssh-key.private_key_openssh
}