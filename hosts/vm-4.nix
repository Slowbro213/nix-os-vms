{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
      ../modules/base.nix
      ../modules/secrets.nix

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops

      ../disko/layout.nix
    ];

  networking.hostName = "vm-4";
  time.timeZone = "Europe/Tirane";

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22  # SSH
      80  # HAProxy HTTP entrypoint
      9100
      9090
      # 443 # if/when you add TLS termination
    ];
  };

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



