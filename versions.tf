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
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.10"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5"
    }

  }
  required_version = ">= 1.11.0"

  cloud { 
    
    organization = "Hashi-RedHat-APJ-Collab" 

    workspaces { 
      name = "aap-demo-test" 
    } 
  } 

}

