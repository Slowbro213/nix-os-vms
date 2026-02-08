{ config, lib, pkgs, hostMeta, inventory, ... }:

let
  nodeName = config.networking.hostName;

  clusterHosts = [ "vm-1" "vm-2" "vm-3" ];

  clusterInventory =
    lib.filterAttrs (name: _: builtins.elem name clusterHosts) inventory;

  serverAddrs =
    lib.mapAttrsToList (_: m: m.address) clusterInventory;
in
{
  services.consul = {
    enable = true;

    webUi = true;

    extraConfig = {
      datacenter = "dc1";
      node_name = nodeName;

      bind_addr = hostMeta.address;
      advertise_addr = hostMeta.address;
      client_addr = "0.0.0.0";

      server = true;
      bootstrap_expect = 3;

      retry_join = serverAddrs;

      data_dir = "/var/lib/consul";

      enable_script_checks = false;
    };
  };

  networking.firewall.allowedTCPPorts = [
    8300 8301 8302 8500 8600
  ];
  networking.firewall.allowedUDPPorts = [
    8301 8302 8600
  ];
}

