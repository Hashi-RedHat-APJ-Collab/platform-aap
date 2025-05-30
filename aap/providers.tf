provider "aap" {
  host                 = "https://${var.domain_name}"
  insecure_skip_verify = true
}