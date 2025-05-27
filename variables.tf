variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "ami_id" {
  type    = string
  default = "ami-0a7aa287b266aba68"
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