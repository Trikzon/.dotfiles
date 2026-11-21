# QEMU/KVM VMs managed by libvirt, used to boot the Windows SSD in place.
# The "default" NAT network is set to autostart by hand: virsh net-autostart default
{ ... }: {
  virtualisation.libvirtd = {
    enable = true;
    # Emulated TPM: Windows 11 blocks feature updates without one.
    qemu.swtpm.enable = true;
  };
  programs.virt-manager.enable = true;
}
