# platform-aap

This Terraform project creates an Ansible Automation Platform (AAP) instance on AWS using a modular approach with infrastructure and configuration management separated into distinct modules. The project provides a complete solution for deploying a secure, production-ready AAP environment with HashiCorp Vault integration for SSH key management.

## Architecture

The project has been refactored to use a modular structure:

- **Root module**: Contains the main configuration that orchestrates all modules
- **aap_instance module**: Contains all the infrastructure resources (VPC, EC2, ALB, etc.)
- **vault_ssh module**: Manages SSH key generation and Vault integration for SSH signing
- **aap_postinstall module**: Handles AAP configuration, job templates, and execution

This separation of concerns allows for independent development and testing of infrastructure, security, and configuration components, making the project more maintainable and flexible.

## Dependencies

This project has several key dependencies:

1. **AMI ID**: Requires an AMI ID from the output of the "demo-packer-aap" project, which creates a pre-configured AAP image
2. **HashiCorp Vault**: Integrates with Vault for SSH key signing and credential management
3. **AWS Resources**: Requires appropriate AWS permissions to create VPC, EC2, Route53, and ALB resources
4. **Let's Encrypt**: Uses ACME protocol for TLS certificate generation

## Prerequisites

Before you begin, ensure you have:

- AWS CLI configured with appropriate credentials
- Terraform v1.0.0 or newer installed
- Access to HashiCorp Vault for SSH key signing
- A registered domain in Route53 (for ALB and TLS setup)
- The AMI ID from a successful build of the demo-packer-aap project

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/Hashi-RedHat-APJ-Collab/platform-aap.git
   cd platform-aap
   ```

2. Copy the example variables file:
   ```bash
   cp terraform.auto.tfvars.example terraform.auto.tfvars
   ```

3. Edit `terraform.auto.tfvars` with your specific values:
   ```hcl
   ami_id            = "ami-xxxxxxxxx"  # From packer build
   acme_email        = "your-email@example.com"
   domain_name       = "aap.yourdomain.com"
   route53_zone_name = "yourdomain.com."
   aap_username      = "admin"
   aap_password      = "your-secure-password"
   ```

3. Set the AWS region environment variable (required for ACME):
   ```bash
   export AWS_REGION=ap-southeast-2
   ```

4. Initialize and apply Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module Structure

The project is organized into a modular structure:

```text
.
├── main.tf                    # Root module calling submodules
├── variables.tf               # Root module variables
├── output.tf                  # Root module outputs
├── providers.tf               # Provider configurations
├── versions.tf                # Version constraints
├── vault.tf                   # Vault provider configuration
├── aap_instance/              # AAP infrastructure module
│   ├── main.tf                # Infrastructure resources
│   ├── alb.tf                 # ALB and certificate resources
│   ├── variables.tf           # Module variables
│   ├── outputs.tf             # Module outputs
│   └── versions.tf            # Module version constraints
├── vault_ssh/                 # Vault SSH signing module
│   ├── main.tf                # SSH key generation and Vault integration
│   ├── variables.tf           # Module variables
│   ├── outputs.tf             # Module outputs
│   └── versions.tf            # Module version constraints
└── aap_postinstall/           # AAP configuration module
    ├── main.tf                # AAP job configuration and execution
    ├── variables.tf           # Module variables
    ├── outputs.tf             # Module outputs
    └── versions.tf            # Module version constraints
```

## Module Dependencies

The modules have the following dependencies:

- **vault_ssh module**: Generates SSH keys and integrates with Vault for SSH signing
- **aap_instance module**: Creates the infrastructure needed to host the AAP instance
- **aap_postinstall module**: Depends on both the aap_instance and vault_ssh modules:
  - Uses the public IP from the AAP instance
  - Uses SSH keys from vault_ssh
  - Waits for the ALB healthy target before executing jobs
  - Uses the domain configuration for URL construction

## ⚠️ ACME + Route 53 DNS Challenge: Region Requirement

This project uses the [ACME Terraform provider](https://registry.terraform.io/providers/vancluever/acme/latest) to automatically generate TLS certificates from Let's Encrypt using the DNS-01 challenge via AWS Route 53.

By design, the ACME provider does **not inherit the AWS region** from the standard `provider "aws"` block in Terraform. Instead, it relies on the AWS SDK to resolve hosted zones — and the SDK requires the region to be explicitly set via environment variables.

To ensure successful DNS challenge resolution, **you must export the AWS region before running Terraform**:

```bash
export AWS_REGION=ap-southeast-2
```

Without this, Terraform will fail during acme_certificate creation with an error like:

```text
failed to determine hosted zone ID: operation error Route 53: ListHostedZonesByName, ...
Invalid Configuration: Missing Region
```

## Outputs

The root module exposes outputs from all submodules:

### Infrastructure Outputs (from aap_instance module)

- `public_ip`: Public IP address of the AAP instance
- `public_fqdn`: Public FQDN of the AAP instance
- `instance_id`: ID of the AAP instance
- `alb_dns_name`: DNS name of the ALB (if created)
- `route53_record_name`: Route53 record name for the ALB (if created)
- `vpc_id`: ID of the VPC
- `security_group_id`: ID of the security group
- `key_pair_name`: Name of the key pair
- `private_key_pem`: Private key in PEM format (sensitive)

### Vault SSH Outputs (from vault_ssh module)

- `unsigned_ssh_public_key`: SSH unsigned public key
- `unsigned_ssh_private_key`: SSH unsigned private key (sensitive)
- `approle_role_id`: Vault AppRole role ID
- `approle_secret_id`: Vault AppRole secret ID (sensitive)

### AAP Configuration Outputs (from aap_postinstall module)

- `aap_job_template_id`: ID of the AAP job template
- `aap_url`: AAP URL (either ALB domain or instance IP)
- `aap_job_id`: ID of the executed AAP job

## Security Features

This project implements several security best practices:

1. **TLS Encryption**: Automatic HTTPS setup with Let's Encrypt certificates
2. **Private Key Protection**: Sensitive outputs are marked as such in Terraform
3. **SSH Key Signing**: Integration with HashiCorp Vault for SSH certificate authentication
4. **Network Isolation**: Custom VPC with private subnets and security groups
5. **Least Privilege**: IAM roles with minimum required permissions

## Infrastructure Components

The `aap_instance` module provisions:

- A custom VPC with public and private subnets
- An EC2 instance with the AAP AMI
- An Application Load Balancer with HTTPS listeners (optional)
- Route53 DNS records for the ALB or EC2 instance
- Security groups with least-privilege access controls
- TLS certificates via Let's Encrypt and ACME protocol
- SSH key pair for instance access

## Maintenance

Regular maintenance tasks include:

- Updating the AMI ID when new AAP versions are released
- Reviewing security group rules periodically
- Rotating credentials (if not using Vault dynamic credentials)
- Updating Terraform providers when new versions are available

## Troubleshooting

Common issues and solutions:

1. **Certificate Generation Failures**: Ensure AWS_REGION is set and Route53 has proper permissions
2. **Connection Timeouts**: Check security group rules and network ACLs
3. **AAP Job Failures**: Examine AAP logs via the web UI or SSH into the instance

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with a clear description of changes

## License

This project is licensed under the Mozilla Public License 2.0 - see the LICENSE file for details.

## Related Projects

- [demo-packer-aap](https://github.com/Hashi-RedHat-APJ-Collab/demo-packer-aap): Creates the AAP AMI used by this project
- [platform-vault-config](https://github.com/Hashi-RedHat-APJ-Collab/platform-vault-config): Configures Vault for integration with AAP
- [platform-aap-vault-config](https://github.com/Hashi-RedHat-APJ-Collab/platform-aap-vault-config): Additional Vault configuration for AAP