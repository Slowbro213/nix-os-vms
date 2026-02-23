{ config, pkgs, lib, inventory, hostMeta, ... }:

let
  vip = "192.168.1.100";
  routerId = 51;

  matches =
    lib.attrNames (lib.filterAttrs (_if: cfg:
      builtins.any (a: a.address == hostMeta.address) (cfg.ipv4.addresses or [])
      || builtins.any (a: a.address == hostMeta.address) (cfg.ipv6.addresses or [])
    ) config.networking.interfaces);

  iface =
    if matches != [] then lib.head matches
    else (config.networking.primaryInterface or "enp0s3");

  hasRole = role: host:
    let roles = host.roles or [];
    in builtins.elem role roles;

  invList =
    lib.mapAttrsToList (name: host: { inherit name host; }) inventory;

  garageNodes =
    builtins.filter (x: hasRole "garage" x.host) invList;

  lbNodes =
    builtins.filter (x: hasRole "lb" x.host) invList;

  lbNamesSorted =
    builtins.sort (a: b: a < b) (map (x: x.name) lbNodes);

  isLb = hasRole "lb" (inventory.${config.networking.hostName} or {});
  isMaster =
    isLb && (lbNamesSorted != []) && (config.networking.hostName == builtins.head lbNamesSorted);

  haproxyServers =
    lib.concatStringsSep "\n"
      (lib.imap0 (i: x:
        let
          sname = "g${toString (i + 1)}";
          addr = x.host.address;
        in "        server ${sname} ${addr}:3900 check"
      ) garageNodes);

in
{
  config = lib.mkIf isLb {

    boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

    services.haproxy = {
      enable = true;
      config = ''
        global
          log /dev/log local0
          maxconn 5000
          daemon

        defaults
          log global
          mode tcp
          option tcplog
          timeout connect 5s
          timeout client  1m
          timeout server  1m

        frontend garage_s3_in
          bind ${vip}:3900
          default_backend garage_s3_nodes

        backend garage_s3_nodes
          balance roundrobin
          option tcp-check
${haproxyServers}
      '';
    };

    services.keepalived = {
      enable = true;
      openFirewall = false;

      vrrpScripts.chk_haproxy = {
        script = "${pkgs.coreutils}/bin/pidof haproxy";
        interval = 2;
        weight = -50;
      };

      vrrpInstances.garageVIP = {
        interface = iface;
        virtualRouterId = routerId;

        state = if isMaster then "MASTER" else "BACKUP";
        priority = if isMaster then 110 else 100;

        virtualIps = [
          { addr = "${vip}/24"; }
        ];
        trackScripts = [ "chk_haproxy" ];
      };
    };
  };
}

