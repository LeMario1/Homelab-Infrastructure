pve0

Description
This is the main virtualization server. It hosts the docker host (which is mainly a media server,) truenas, a pterodactly vm, and test workoads such as disposable k3s clusters and terraform tests.

Hardware
CPU: Intel 11400k
GPU: Intel integrated graphics
Ram: 96GB DDR4
Boot Drive: zfs mirrored 1tb sata ssd
VM Drive: 1tb nvme ssd
Truenas Drives: 2 12tb hdd

Host Configuration
Since this machine hosts a media server with gpu transcoding and a truenas vm, it requires hardware passthrough.
  Hardware Passthrough
    Truenas:
      Passthrough by device ID.
    MediaHost:
      iommu intel gpu passthrough. 
      when running zfs root and systemd-boot edit /etc/kernel/cmdline to include intel_iommu=on iommu=pt
      /etc/kernel/cmdline should look like this root=ZFS=rpool/ROOT/pve-1 boot=zfs intel_iommu=on iommu=pt video=efifb:off,vesafb:off,simplefb:off nomodeset vfio-pci.ids=8086:4c8b
      afterwards, run proxmox-boot-tool refresh to apply.
  Sometimes device naming changes when pci devices are added are removed, renaming the management interface and hiding the management gui. To avoid this problem, we use proxmox-network-interface-pinning tool to permanently rename certain nics.
    nic-pinning:
      run proxmox-network-interface-pinning generate --interface [nameofinterface] --target-name [desiredinterfacename] for each nic you want pinned.
      On this machine we pin 
        eno1 to enNicMgmt0
        enp3s0 to enNicData0
      see [docs](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_using_the_pve_network_interface_pinning_tool) for details
