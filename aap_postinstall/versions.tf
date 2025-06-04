terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aap = {
      source  = "ansible/aap"
      version = ">= 1.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }

  }
} 