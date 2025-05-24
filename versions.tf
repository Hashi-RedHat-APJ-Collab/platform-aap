terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }

  }
  required_version = ">= 1.11.0"

}