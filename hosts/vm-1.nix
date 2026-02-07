{ inputs, config, pkgs, lib, ... }:

let
  backendsDir = ../modules/backends;
  backendFiles =
    builtins.filter (f: lib.hasSuffix ".nix" f)
      (builtins.attrNames (builtins.readDir backendsDir));
  backendImports =
    map (f: backendsDir + ("/" + f)) backendFiles;

  
  servicesDir = ../modules/services;
  serviceFiles =
    builtins.filter (f: lib.hasSuffix ".nix" f)
      (builtins.attrNames (builtins.readDir servicesDir));
  serviceImports =
    map (f: servicesDir + ("/" + f))
      (lib.sort lib.lessThan serviceFiles);
in
{
  imports =
    [
      ../modules/base.nix
      ../modules/secrets.nix

      ../modules/backends.nix

      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops

      ../disko/layout.nix
    ]
    ++ serviceImports
    ++ backendImports;

  networking.hostName = "vm-1";
  time.timeZone = "Europe/Tirane";

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22  # SSH
      80  # HAProxy HTTP entrypoint
      8500
      3901
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

