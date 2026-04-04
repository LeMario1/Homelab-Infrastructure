resource "proxmox_vm_qemu" "terraform_boot_test" {
  name        = "terraform-boot-test"
  target_node = "pve0"
  description = "A test vm managed by terraform."

  clone = "cloud-init-test"

  # Define cpu options
  cpu {
    cores = 2
  }


  # disk must be specified here because of a bug with cloning. Cloning should work, but terraform leaves the disk unnatached, making the machine unbootable.
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
