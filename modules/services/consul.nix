{ config, lib, pkgs, hostMeta, inventory, ... }:

let
  nodeName = config.networking.hostName;

  hasRole = role: host:
    builtins.elem role (host.roles or []);

  # All inventory entries that have the "consul" role
  consulInventory =
    lib.filterAttrs (_name: host: hasRole "consul" host) inventory;

  # Addresses of consul servers
  consulServerAddrs =
    lib.mapAttrsToList (_name: host: host.address) consulInventory;

  isConsulServer = hasRole "consul" (inventory.${nodeName} or {});
  bootstrapExpect = builtins.length consulServerAddrs;
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

      server = isConsulServer;

      bootstrap_expect = bootstrapExpect;

      retry_join = consulServerAddrs;

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
