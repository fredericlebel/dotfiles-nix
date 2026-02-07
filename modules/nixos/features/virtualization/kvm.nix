{
  config,
  lib,
  ...
}:
let
  cfg = config.my.features.virtualization.kvm;
in
{
  options.my.features.virtualization.kvm = {
    enable = lib.mkEnableOption "Optimisations KVM/QEMU (Guest Agent + VirtIO)";
  };

  config = lib.mkIf cfg.enable {
    #imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

    services.qemuGuest.enable = true;

    boot = {
      initrd.availableKernelModules = [
        "virtio_net" # Réseau paravirtualisé
        "virtio_pci" # Bus PCI paravirtualisé
        "virtio_mmio" # Mémoire
        "virtio_blk" # Disque paravirtualisé
        "virtio_scsi" # SCSI paravirtualisé
      ];

      kernelModules = [
        "virtio_balloon" # Permet à l'hôte de récupérer de la RAM si besoin
        "virtio_console" # Console série pour les logs hôte
        "virtio_rng" # Générateur d'entropie (Random Number) rapide depuis l'hôte
      ];
    };

    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="vd[a-z]", ATTR{queue/scheduler}="none"
    '';

    boot.kernel.sysctl = {
      "net.ipv4.tcp_fastopen" = 3;
      "vm.swappiness" = 10;
    };
  };
}
