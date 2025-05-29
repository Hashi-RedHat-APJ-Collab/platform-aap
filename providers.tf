provider "aws" {
  region = var.aws_region
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "aap" {
  host                 = local.aap_url
  insecure_skip_verify = true 
}