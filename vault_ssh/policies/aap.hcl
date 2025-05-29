# Allow verything to be managed in the namespace (not recommended for production environments)
path "*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# # write and manage secrets in key-value secrets engine
# path "secrets/*" {
#   capabilities = [ "create", "read", "update", "delete", "list", "patch" ]
# }