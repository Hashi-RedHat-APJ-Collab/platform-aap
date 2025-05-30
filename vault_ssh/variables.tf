variable "namespace" {
  description = "vault namespace"
  type        = string
}

variable "aap_admin_password" {
  description = "admin password for aap"
  type        = string
}

variable "auth_backend_approle_path" {
  description = "auth backend approle"
  type        = string
  default     = "approle"
}

variable "ssh_role_name" {
  description = "Name of the SSH role for AppRole authentication"
  type        = string
  default     = "ssh_demo"
}