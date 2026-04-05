variable "pm_api_url" {
  type        = string
  description = "URL to reach pve0"
  sensitive   = true
}

variable "pm_user" {
  type        = string
  description = "terraform user of proxmox"
  sensitive   = true
}

variable "pm_password" {
  type        = string
  description = "pm_user password"
  sensitive   = true
}

variable "pm_api_token_id" {
  type        = string
  description = "pm_user token ID"
  sensitive   = true
}

variable "pm_api_token_secret" {
  type        = string
  description = "pm_user api secret"
  sensitive   = true
}
