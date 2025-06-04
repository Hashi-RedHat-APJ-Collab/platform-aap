resource "vault_approle_auth_backend_role" "this" {
  backend         = var.auth_backend_approle_path
  role_name       = var.tenant
  token_policies  = ["aap"]
}


resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = vault_approle_auth_backend_role.this.backend
  role_name = var.tenant
}

resource "vault_identity_entity" "this" {
  name = var.tenant
  metadata = {
    ssh_role_name = var.tenant
  }
}

#create entity alias for the role
resource "vault_identity_entity_alias" "this" {
  name         = vault_approle_auth_backend_role.this.role_id
  mount_accessor = var.approle_mount_accessor
  canonical_id = vault_identity_entity.this.id
}