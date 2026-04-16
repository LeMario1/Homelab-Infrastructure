# pve0
This is the primary virtualization server for the homelab. 

This system runs the bulk of core infrustructure including storage, media services, experimental k3s clusters, test vms, and terraform vms.

# Hardware
| Hardware | Specification |
|----------|---------------|
|CPU | Intel i5-11400k |
|GPU | Intel integrated graphics
|Ram | 96GB DDR4
|Boot Drive | zfs mirrored 1tb sata SSD
|VM Drive | 1tb nvme SSD
|Truenas Drives | 2 12tb HDD (zfs mirror)

# Workoads
| Name | Type | Purpose |
| --- | --- | --- |
| TrueNAS | VM | Storage |
| MediaHost | VM | docker and media services|
| GameVM | VM | manage game servers in pterodactyl |
| K3s0-2 | VM | Test kubernetes |
| pihole2 | LXC | redundant dns forwarder and sinkhole |

# Host Configuration
  ## Hardware Passthrough
  This machine requires hardware passthrough for:
  - Intel iGPU (media transcoding)
  - TrueNAS storage drives
  ### Truenas
  <details>
  <summary>For drives that are passed through by device ID:</summary> 

  On proxmox host, find vm id of TrueNAS:
  ```
  qm list | grep -i truenas
  ```
  Example output:
  ```
  100 TrueNAS             running    32768             32.00 2351353
  ```
  Now find the device ID of the HDD:
  ```
  ls /dev/disk/by-id
  ```
  Example output:
  ```
  ata-XXXXXXXXXXXXX-XXXXXX_XXXXXXXX
  ```
  Edit the vm configuration file under:
  ```
  /etc/pve/qemu-server/100.conf
  ```
  Include in the disk section:
  ```
  scsi1: /dev/disk/by-id/ata-XXXXXXXXXXXXX-XXXXXX_XXXXXXXX,backup=0,iothread=1
  ```
  The disks should be available to TrueNAS now.

  </details>
  
  <details>
  <summary> For HBA passthrough: </summary>

  #### 1. Enable pci passthrough and iommu (see GPU passthrough)
  
  #### 2. Ensure the HBA is in its own iommu group:
  ```bash
  for d in $(find /sys/kernel/iommu_groups/ -type l | sort -n -k5 -t/); do 
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done;
  ```
Example output: (make sure its the only member of its group)
```
IOMMU Group 14 01:00.0 RAID bus controller [0104]: Broadcom / LSI SAS2008 PCI-Express Fusion-MPT SAS-2 [Falcon] [1000:0072] (rev 03)
```
#### 3. Attach HBA to VM
In the Proxmox web interface:

1) Select the VM
2) Click Hardware
3) Click add PCI Device
4) Select the HBA card
5) Click Adavnced
6) Turn Rom-Bar off
7) Confrim and start VM
  </details>

  ### MediaHost GPU passthrough
  GPU passthrough is achieved by the following steps:
  1) Enable iommu
  2) Bind igpu to vfio by pci ID
  3) Disable framebuffer drivers
  3) Pass gpu to vm
  > [!WARNING]
  > Passing through the only gpu on the system locks out the direct terminal in proxmox.
  #### 1. Enable iommu      
  When running zfs root and systemd-boot, edit:  
   ```
   /etc/kernel/cmdline
   ``` 
   to include the following kernel parameters:  
   ```
   intel_iommu=on iommu=pt
   ```  
   example configuration: 
   ```
   root=ZFS=rpool/ROOT/pve-1 boot=zfs intel_iommu=on iommu=pt
   ```  
  Apply the change:
  ```
  proxmox-boot-tool refresh
  ```
  #### 2. Bind igpu to vfio
  Find gpu pci id with:
  ```
  lspci -nn | grep graphics -i
  ```
  Example output:
  ```
  01:00.0 VGA compatible controller [0300]: Intel Corporation RocketLake-S GT1 [UHD Graphics 730] [8086:4c8b] (rev 04)
  ```
  This is the pci id in this example:
  ```
  [8086:4c8b]
  ```
  Bind pci id to vfio by editing:
  ```
  /etc/kernel/cmdline
  ```
  To include:
  ```
  vfio-pci.ids=8086:4c8b
  ```
  Example configuration:
  ```
  root=ZFS=rpool/ROOT/pve-1 boot=zfs intel_iommu=on iommu=pt vfio-pci.ids=8086:4c8b
  ```
  #### 3. Disable framebuffer drivers
  edit:
  ```
  /etc/kernel/cmdline
  ```
  To include:
  ```
  video=efifb:off,vesafb:off,simplefb:off nomodeset
  ```
  Example configuration:
  ```
  root=ZFS=rpool/ROOT/pve-1 boot=zfs intel_iommu=on iommu=pt video=efifb:off,vesafb:off,simplefb:off nomodeset vfio-pci.ids=8086:4c8b
  ```
  #### 4. Apply the changes
  Run:
  ```
  proxmox-boot-tool refresh
  ```
  Then **reboot**.
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
  

  Pinned interface configs are stored in:
  ```
  /usr/local/lib/systemd/network/
  ```


  see [docs](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_using_the_pve_network_interface_pinning_tool) for details on proxmox-network-interface-pinning

## Backup Strategy
### Host config backup
Backup
1) pve
2) Pinned nics
3) Interfaces
34) Boot parameters
5) Kernel modules
6) Kernel module paramters
7) Hosts
8) Hostname
9) SSH keys
```
cd / && \
tar -czf backup.tar.gz / \
etc/pve \
usr/local/lib/systemd/network \
etc/network/interfaces \
etc/kernel/cmdline \
etc/modules \
etc/modprobe.d \
etc/hosts \
etc/hostname \
root/.ssh
```
Or:
```
tar -czf backup.tar.gz etc
```
Restore them manually
Run:
```
proxmox-boot-tool refresh
```
Reboot:
```
reboot now
```
ssh into a different node on the  cluster:
```
ssh root@192.168.88.246
```
run:
```
pvecm delnode pve0
```
then join pve0 back into the cluster:
```
pvecm add 192.168.88.200
```
