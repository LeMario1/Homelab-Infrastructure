# pve0
This is the primary virtualization server for the homelab. 

This system runs the bulk of core infrustructure including storage, media services, experimental k3s clusters, test vms, and terraform vms.

# Hardware
| Hardware | Specification |
|----------|---------------|
|CPU | Intel i5-11400k |
|CPU | Intel 11400k
|GPU | Intel integrated graphics
|Ram | 96GB DDR4
|Boot Drive | zfs mirrored 1tb sata SSD
|VM Drive | 1tb nvme SSD
|Truenas Drives | 2 12tb HDD

# Workoads
| Name | Type | Purpose |
| --- | --- | --- |
| TrueNAS | VM | Storage |
| MediaHost | VM | docker and media services|
| GameVM | VM | manage game servers in pterodactyl |
K3s0-2 | VM | Test kubernetes |
| pihole2 | LXC | redundant dns forwarder and sinkhole |

# Host Configuration
  ## Hardware Passthrough
  This machine requires hardware passthrough for:
  - Intel iGPU (media transcoding)
  - TrueNAS storage drives
  ### Truenas
  Drives are passed through by device ID.
  ### MediaHost GPU passthrough
  When running zfs root and systemd-boot, edit:  
   ```
   /etc/kernel/cmdline
   ``` 
   to include the following kernel paramaters:  
   ```
   intel_iommu=on iommu=pt
   ```  
   example configuration: 
   ```
   root=ZFS=rpool/ROOT/pve-1 boot=zfs intel_iommu=on iommu=pt video=efifb:off,vesafb:off,simplefb:off nomodeset vfio-pci.ids=8086:4c8b
   ```  
  Apply the change:
  ```
  proxmox-boot-tool refresh
  ```
  ## nic-pinning
  Sometimes device naming changes when pci devices are added are removed, which renames the management interface and hides the management gui.   
  
  To avoid this problem, we use [proxmox-network-interface-pinning](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_using_the_pve_network_interface_pinning_tool) tool to permanently rename certain nics.

  To pin individual nics:

  ```
  proxmox-network-interface-pinning generate --interface <current-interface-name> -target-name <desired-interface-name>
  ``` 
  On this machine we pin:
  | Original | Pinned Name |
  | --- | --- | 
  |eno1 | enNicMgmt0
  |enp3s0 | enNicData0|
  see [docs](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_using_the_pve_network_interface_pinning_tool) for details on proxmox-network-interface-pinning
