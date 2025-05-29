# resource "vault_auth_backend" "approle" {
#   type = "approle"

#   tune {
#     default_lease_ttl = "2190h"
#     max_lease_ttl     = "4380h"
#   }
  
#   namespace = var.namespace
# }

resource "vault_approle_auth_backend_role" "this" {
  backend         = var.auth_backend_approle_path
  role_name       = "aap"
  token_policies  = ["aap"]

  namespace = var.namespace
}

resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.this.role_name

  namespace = var.namespace
}

resource "vault_auth_backend" "this" {
  type = "userpass"

  namespace = var.namespace
}