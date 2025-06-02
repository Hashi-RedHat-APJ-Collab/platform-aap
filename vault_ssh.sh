#!/bin/zsh

# === CONFIGURATION ===
VAULT_NAMESPACE="admin/hashi-redhat"
VAULT_ADDR="https://tf-aap-public-vault-76d1afab.7739a0fc.z1.hashicorp.cloud:8200"
GITHUB_TOKEN="${GITHUB_TOKEN}"  # must be set in your environment
EMAIL="simon.lynch@hashicorp.com"  # update this
SSH_SUBDIR="gcve"  # update if needed
VAULT_SIGN_PATH="/ssh/sign/demo"  # update if needed

# === DERIVED VARIABLES ===
SSH_DIR="$HOME/.ssh/${SSH_SUBDIR}"
PRIVATE_KEY_PATH="${SSH_DIR}/id_ed25519"
PUBLIC_KEY_PATH="${PRIVATE_KEY_PATH}.pub"
CERT_PATH="${PRIVATE_KEY_PATH}-cert.pub"

# === FUNCTIONS ===

function check_env_vars() {
  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "❌ GITHUB_TOKEN environment variable is not set."
    exit 1
  fi
}

function create_ssh_directory() {
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
}

function generate_ssh_key() {
  if [[ -f "$PRIVATE_KEY_PATH" ]]; then
    echo "🔑 SSH key already exists at $PRIVATE_KEY_PATH — skipping generation."
  else
    echo "🔧 Generating SSH key..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$PRIVATE_KEY_PATH" -N ""
  fi
}

function authenticate_to_vault() {
  echo "🔐 Logging into Vault..."
  export VAULT_NAMESPACE
  export VAULT_ADDR
  export role_id
  export secret_id
  #export VAULT_TOKEN=$(vault login -method=github token="$GITHUB_TOKEN" -format=json | jq -r '.auth.client_token')
  export VAULT_TOKEN=$(vault write auth/approle/login role_id=${role_id} secret_id=${secret_id} -format=json | jq -r '.auth.client_token')
}

function sign_ssh_key() {
  echo "✍️  Signing public key with Vault..."
  vault write -namespace="$VAULT_NAMESPACE" -field=signed_key "$VAULT_SIGN_PATH" public_key=@"$PUBLIC_KEY_PATH" > "$CERT_PATH"
  chmod 644 "$CERT_PATH"
  echo "✅ Signed certificate written to $CERT_PATH"
}

function show_ssh_usage() {
  echo ""
  echo "You can now SSH using:"
  echo "ssh -i $PRIVATE_KEY_PATH vm_user@<dns-or-ip-address>"
}

# === MAIN EXECUTION ===

check_env_vars
create_ssh_directory
generate_ssh_key
authenticate_to_vault
sign_ssh_key
show_ssh_usage