variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "ami_id" {
  type    = string
  default = "ami-0a7aa287b266aba68"
}

variable "create_alb" {
  description = "Whether to create ALB, ACME certificate, and Route53 resources"
  type        = bool
  default     = true
}

variable "acme_email" {
  description = "Email address for Let's Encrypt registration"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Optional SANs (Subject Alternative Names) for the certificate"
  type        = list(string)
  default     = []
}

variable "route53_zone_name" {
  description = "The name of the Route 53 hosted zone to use (must end with a dot)"
  type        = string
}

variable "aap_username" {
  description = "Username for AAP"
  type        = string
}

variable "aap_password" {
  description = "Password for AAP"
  type        = string
}
variable "job_template_name" {
  description = "Name of the AAP job template to run"
  type        = string
  default     = "Hashicorp Vault demo setup"
}

variable "tenant" {
  description = "Tenant for the AAP job"
  type        = string
  default     = "demo"
}

variable "machine_user" {
  description = "Machine user for AAP"
  type        = string
  default     = "ec2-user"
}