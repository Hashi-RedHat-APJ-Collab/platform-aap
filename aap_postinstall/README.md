# AAP Configuration Module

This Terraform module configures Ansible Automation Platform (AAP) jobs and manages SSH keys for Vault integration. It's designed to work with the `aap_instance` module that provides the underlying infrastructure.

## Resources Created

- **TLS Private Key**: ED25519 SSH key pair for secure communication
- **HTTP Data Source**: Retrieves AAP job template information via API
- **AAP Job**: Executes the Vault credentials configuration job template

## Usage

```hcl
module "aap_config" {
  source = "./aap"

  # Required variables
  domain_name              = "aap.example.com"
  aap_instance_public_ip   = module.aap_instance.public_ip
  aap_username            = "admin"
  aap_password            = "your-secure-password"
  
  # Optional variables
  create_alb              = true
  job_template_name       = "Hashicorp Vault demo setup"
  tenant                  = "demo"
  machine_user            = "ec2-user"
  wait_for_healthy_target = module.aap_instance.wait_for_healthy_target
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | Domain name for AAP (used when ALB is enabled) | `string` | n/a | yes |
| aap_instance_public_ip | Public IP of the AAP instance (used when ALB is disabled) | `string` | n/a | yes |
| aap_username | Username for AAP authentication | `string` | n/a | yes |
| aap_password | Password for AAP authentication | `string` | n/a | yes |
| create_alb | Whether ALB is created (affects AAP URL construction) | `bool` | `true` | no |
| job_template_name | Name of the AAP job template to run | `string` | `"Hashicorp Vault demo setup"` | no |
| tenant | Tenant for the AAP job | `string` | `"demo"` | no |
| machine_user | Machine user for AAP | `string` | `"ec2-user"` | no |
| wait_for_healthy_target | Dependency object to wait for healthy target | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| aap_job_template_id | ID of the AAP job template |
| ssh_unsigned_public_key | SSH unsigned public key |
| ssh_unsigned_private_key | SSH unsigned private key (sensitive) |
| aap_url | AAP URL (either ALB domain or instance IP) |
| aap_job_id | ID of the executed AAP job |

## Dependencies

This module depends on:
- An AAP instance being available and healthy
- Proper AAP authentication credentials
- The specified job template existing in AAP

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.11.0 |
| aap | >= 0.0.1 |
| tls | >= 3.0 |
| http | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aap | >= 0.0.1 |
| tls | >= 3.0 |
| http | >= 3.0 |

## Notes

- The module automatically determines the AAP URL based on whether an ALB is created
- SSH keys are generated using ED25519 algorithm for enhanced security
- The module waits for the target to be healthy before executing AAP jobs
- All sensitive outputs are properly marked as sensitive 