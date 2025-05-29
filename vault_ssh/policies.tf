# # namespace policies (created in the root/admin namespace)
# resource "vault_policy" "namespace" {
#   name = var.namespace

#   policy = <<EOT
# path "${var.namespace}/sys/policies/*" {
#    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
# }
# EOT
# }

# loop over the policies directory and create policies.
resource "vault_policy" "this" {
  for_each = fileset("${path.module}/policies", "*.hcl")
  
  name     = trimsuffix(each.value, ".hcl")
  policy   = file("${path.module}/policies/${each.value}")

  namespace = var.namespace
}