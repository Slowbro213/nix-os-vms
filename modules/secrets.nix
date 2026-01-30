{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  # Example secret
  sops.secrets."grafana/admin-password" = {
    owner = "root";
    mode = "0400";
  };
}

