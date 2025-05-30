variable "create_alb" {
  description = "Whether ALB is created (affects AAP URL construction)"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for AAP (used when ALB is enabled)"
  type        = string
}

variable "aap_instance_public_ip" {
  description = "Public IP of the AAP instance (used when ALB is disabled)"
  type        = string
}

variable "job_template_name" {
  description = "Name of the AAP job template to run"
  type        = string
  default     = "Hashicorp Vault demo setup"
}

variable "aap_username" {
  description = "Username for AAP authentication"
  type        = string
}

variable "aap_password" {
  description = "Password for AAP authentication"
  type        = string
  sensitive   = true
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

variable "wait_for_healthy_target" {
  description = "Dependency object to wait for healthy target"
  type        = any
  default     = null
} 