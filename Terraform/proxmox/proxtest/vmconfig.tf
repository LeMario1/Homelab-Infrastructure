resource "proxmox_vm_qemu" "terraform_boot_test" {
  name        = "terraform-boot-test"
  target_node = "pve0"

  clone = "cloud-init-test"

  scsihw = "virtio-scsi-single"

  disks {
    scsi {
      scsi0 {
        disk {
          storage    = "zfs-nvme"
          size       = 16
          emulatessd = true
          iothread   = false
          discard    = true
          backup     = true
          replicate  = true
        }
      }
    }
  }
}
