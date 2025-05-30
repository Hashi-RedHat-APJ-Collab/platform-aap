resource "vault_mount" "kvv2" {
  path        = "secrets"
  type        = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
  description = "kv-v2 secrets engine for the ${var.namespace} team"

  namespace = var.namespace
}


resource "vault_kv_secret_v2" "aap" {
  mount                      = vault_mount.kvv2.path
  name                       = "${var.tenant}/aap-ssh"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    ssh-unsigned-public-key = tls_private_key.ssh-key.public_key_openssh,
    ssh-unsigned-private-key = tls_private_key.ssh-key.private_key_openssh,
  }
  )

  namespace = var.namespace
}