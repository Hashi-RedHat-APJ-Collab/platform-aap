resource "vault_kv_secret_v2" "aap" {
  mount                      = var.kvv2_mount_path
  name                       = "${var.tenant}"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    ssh-unsigned-public-key = tls_private_key.ssh-key.public_key_openssh,
    ssh-unsigned-private-key = tls_private_key.ssh-key.private_key_openssh,
    value                 = var.tenant
  }
  )

}