{ config, pkgs, lib, ... }:

{

  imports =
    [
      ../modules/services/promtail.nix
    ];

  environment.systemPackages = with pkgs; [ git vim ];

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [ 
      "systemd"
      "cpu"
      "meminfo"
      "filesystem"
      "loadavg"
      "netdev"
    ];
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22
      80
      3000
      8500
      3900
      3901
      9100
      9090
      # 443 # if/when you add TLS termination
    ];
  };

  #SSH
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
    PubkeyAuthentication = true;
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  # This is a public key
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzUvw59McgsCCf+ucUaclE6M9C/UKIQ1YdwF7eoYQs+ vboxuser@virtualbox"
  ];

  security.sudo.wheelNeedsPassword = false;

}


