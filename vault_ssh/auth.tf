resource "vault_approle_auth_backend_role" "this" {
  backend         = var.auth_backend_approle_path
  role_name       = var.ssh_role_name
  token_policies  = ["aap"]

}


resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = var.auth_backend_approle_path
  role_name = vault_approle_auth_backend_role.this.role_name

}
#create entity alias for the role
resource "vault_identity_entity_alias" "this" {
  name         = var.ssh_role_name
  mount_accessor = vault_approle_auth_backend_role.this.id
  canonical_id = vault_approle_auth_backend_role.this.role_id

}