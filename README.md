# platform-aap

This Terraform project creates an Ansible Automation Platform (AAP) instance on AWS using a modular approach with infrastructure and configuration management separated into distinct modules.

## Architecture

The project has been refactored to use a modular structure:

- **Root module**: Contains the main configuration that orchestrates both infrastructure and AAP configuration modules
- **aap_instance module**: Contains all the infrastructure resources (VPC, EC2, ALB, etc.)
- **aap module**: Contains AAP job configuration and SSH key management for Vault integration

## Dependencies

This project expects an "ami_id" from the output of the "demo-packer-aap" project.

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.auto.tfvars.example terraform.auto.tfvars
   ```

2. Edit `terraform.auto.tfvars` with your specific values:
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

```
.
├── main.tf                    # Root module calling both submodules
├── variables.tf               # Root module variables
├── output.tf                  # Root module outputs
├── providers.tf               # Provider configurations
├── versions.tf                # Version constraints
├── aap_instance/              # AAP infrastructure module
│   ├── main.tf                # Infrastructure resources
│   ├── alb.tf                 # ALB and certificate resources
│   ├── variables.tf           # Module variables
│   ├── outputs.tf             # Module outputs
│   ├── versions.tf            # Module version constraints
│   └── README.md              # Module documentation
└── aap/                       # AAP configuration module
    ├── aap.tf                 # AAP job and SSH key resources
    ├── providers.tf           # AAP provider configuration
    ├── variables.tf           # Module variables
    ├── outputs.tf             # Module outputs
    ├── versions.tf            # Module version constraints
    └── README.md              # Module documentation
```

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

The root module exposes outputs from both submodules:

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

### AAP Configuration Outputs (from aap module)
- `aap_job_template_id`: ID of the AAP job template
- `ssh_unsigned_public_key`: SSH unsigned public key
- `ssh_unsigned_private_key`: SSH unsigned private key (sensitive)
- `aap_url`: AAP URL (either ALB domain or instance IP)
- `aap_job_id`: ID of the executed AAP job

## Module Dependencies

The `aap` module depends on the `aap_instance` module:
- Uses the public IP from the AAP instance
- Waits for the healthy target before executing jobs
- Uses the same domain configuration for URL construction