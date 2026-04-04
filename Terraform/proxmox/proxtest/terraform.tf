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

  pm_api_url      = "https://192.168.88.200:8006/api2/json"
  pm_user         = "terraform@pve"
  pm_password     = "Zeepnog88!"
  pm_tls_insecure = "true"
}
