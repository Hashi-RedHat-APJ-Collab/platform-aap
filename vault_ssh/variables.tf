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