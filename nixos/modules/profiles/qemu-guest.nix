# Common configuration for virtual machines running under QEMU (using
# virtio).

{ config, lib, ... }:

{
  boot.initrd.availableKernelModules = [  ];
  boot.initrd.kernelModules = [  ];

  boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable)
    ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';
}
