
# loop over the policies directory and create policies.
resource "vault_policy" "this" {
  for_each = fileset("${path.module}/policies", "*.hcl")
  
  name     = trimsuffix(each.value, ".hcl")
  policy   = file("${path.module}/policies/${each.value}")

  namespace = var.namespace
}