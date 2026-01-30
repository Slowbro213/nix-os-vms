{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ../modules/base.nix
    ../modules/secrets.nix

    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops

    ../disko/layout.nix
  ];

  networking.hostName = "test-vm";
  time.timeZone = "Europe/Tirane";

  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
    PubkeyAuthentication = true;
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzUvw59McgsCCf+ucUaclE6M9C/UKIQ1YdwF7eoYQs+ vboxuser@virtualbox"
  ];

  security.sudo.wheelNeedsPassword = false;

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
  system.stateVersion = "26.05";
}

