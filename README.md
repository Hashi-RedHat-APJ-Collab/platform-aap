# platform-aap

## This repo is dependent on AAP containerized packer build



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