provider "aws" {
  region = var.aws_region
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "vault" {
  # Configuration should be provided via environment variables:
  # VAULT_ADDR, VAULT_TOKEN, etc.
}

provider "tls" {
  # No configuration needed
}

