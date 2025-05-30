# AAP Instance Module

This Terraform module creates an Ansible Automation Platform (AAP) instance on AWS with the following components:

## Resources Created

- **VPC and Networking**: VPC, Internet Gateway, Route Tables, and Public Subnets in two Availability Zones
- **Security Groups**: Security groups for the AAP instance and ALB (if enabled)
- **EC2 Instance**: AAP controller instance with associated key pair
- **Application Load Balancer** (optional): ALB with HTTPS/HTTP listeners, target groups, and health checks
- **SSL Certificate** (optional): ACME/Let's Encrypt certificate for HTTPS
- **Route53 DNS** (optional): DNS record pointing to the ALB

## Usage

```hcl
module "aap_instance" {
  source = "./aap_instance"

  # Required variables
  ami_id            = "ami-0a7aa287b266aba68"
  acme_email        = "admin@example.com"
  domain_name       = "aap.example.com"
  route53_zone_name = "example.com."
  
  # Optional variables
  aws_region               = "ap-southeast-2"
  create_alb               = true
  subject_alternative_names = ["aap-alt.example.com"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami_id | AMI ID for the EC2 instance | `string` | n/a | yes |
| acme_email | Email address for Let's Encrypt registration | `string` | n/a | yes |
| domain_name | Primary domain name for the certificate | `string` | n/a | yes |
| route53_zone_name | The name of the Route 53 hosted zone to use (must end with a dot) | `string` | n/a | yes |
| aws_region | AWS region | `string` | `"ap-southeast-2"` | no |
| create_alb | Whether to create ALB, ACME certificate, and Route53 resources | `bool` | `true` | no |
| subject_alternative_names | Optional SANs (Subject Alternative Names) for the certificate | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| public_ip | Public IP address of the AAP instance |
| public_fqdn | Public FQDN of the AAP instance |
| instance_id | ID of the AAP instance |
| alb_dns_name | DNS name of the ALB |
| route53_record_name | Route53 record name for the ALB |
| vpc_id | ID of the VPC |
| security_group_id | ID of the security group |
| subnet_az1_id | ID of the public subnet in AZ1 |
| subnet_az2_id | ID of the public subnet in AZ2 |
| key_pair_name | Name of the key pair |
| private_key_pem | Private key in PEM format (sensitive) |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| acme | ~> 2.0 |
| tls | >= 3.0 |
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| acme | ~> 2.0 |
| tls | >= 3.0 |
| random | >= 3.0 | 