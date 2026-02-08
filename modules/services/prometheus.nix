{ config, lib, inventory, ... }:

let
  targets = lib.mapAttrsToList (_: m: "${m.address}:9100") inventory;
in
{
  services.prometheus = {
    enable = true;
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = targets; }
        ];
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 9090 ];
}

