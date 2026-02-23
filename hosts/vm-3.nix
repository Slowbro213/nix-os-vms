{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
      ../modules/base.nix
      ../modules/secrets.nix
      ../modules/services/garage.nix

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops

      ../disko/layout.nix
    ];

  networking.hostName = "vm-3";
  time.timeZone = "Europe/Tirane";

  boot.kernel.sysctl = {
    "net.core.somaxconn" = 8192;
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "fs.file-max" = 1048576;
  };

  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
  ];


  boot.loader.grub.enable = true;
  boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
  system.stateVersion = "26.05";
}


