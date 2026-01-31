{ inputs, config, pkgs, lib, ... }:

let
  servicesDir = ../modules/backends;
  serviceFiles =
    builtins.filter (f: lib.hasSuffix ".nix" f)
      (builtins.attrNames (builtins.readDir servicesDir));
  serviceImports =
    map (f: servicesDir + ("/" + f)) serviceFiles;
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
    ++ serviceImports;

  networking.hostName = "test-vm";
  time.timeZone = "Europe/Tirane";

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
  system.stateVersion = "26.05";
}

