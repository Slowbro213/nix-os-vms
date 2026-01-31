{ inputs, config, pkgs, lib, ... }:

let
  backendServicesDir = ../modules/backends;
  backendServiceFiles =
    builtins.filter (f: lib.hasSuffix ".nix" f)
      (builtins.attrNames (builtins.readDir backendServicesDir));
  backendServiceImports =
    map (f: backendServicesDir + ("/" + f)) backendServiceFiles;

  serviceModulesDir = ../modules/services;
  serviceModuleFiles =
    builtins.filter (f: lib.hasSuffix ".nix" f)
      (builtins.attrNames (builtins.readDir serviceModulesDir));
  serviceModuleImports =
    map (f: serviceModulesDir + ("/" + f)) serviceModuleFiles;
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
    ++ backendServiceImports
    ++ serviceModuleImports;

  networking.hostName = "test-vm";
  time.timeZone = "Europe/Tirane";

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
  system.stateVersion = "26.05";
}
