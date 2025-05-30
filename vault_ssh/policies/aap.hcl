# Policy for AppRole authentication with SSH key signing capabilities
# Designed for use in the admin/hashi-redhat namespace
# Uses templating based on entity name

# Allow access to SSH secrets engine for signing with the entity's role
path "ssh/sign/{{identity.entity.name}}" {
    capabilities = ["create", "update"]
}

# Allow reading SSH CA public key
path "ssh/public_key" {
    capabilities = ["read"]
}

# Allow reading the entity's SSH role configuration
path "ssh/roles/{{identity.entity.name}}" {
    capabilities = ["read"]
}

# Allow access to KV secrets engine for the entity's tenant
path "secrets/data/{{identity.entity.name}}/*" {
    capabilities = ["create", "read", "update", "delete", "list", "patch"]
}

path "secrets/metadata/{{identity.entity.name}}/*" {
    capabilities = ["create", "read", "update", "delete", "list", "patch"]
}

# Allow reading own token information
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow renewing own token
path "auth/token/renew-self" {
    capabilities = ["update"]
}