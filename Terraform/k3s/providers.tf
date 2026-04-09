terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  # Configuration options

  pm_api_url = var.pm_api_url
  #pm_user             = var.pm_user
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  #pm_password     = var.pm_password
  pm_tls_insecure = "true"
}
