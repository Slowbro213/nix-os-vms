{ config, pkgs, lib, inventory, ... }:

let
  hasRole = role: host:
    builtins.elem role (host.roles or []);

  invList = lib.mapAttrsToList (name: host: { inherit name host; }) inventory;

  loggingNodes = builtins.filter (x: hasRole "logging" x.host) invList;

  lokiClients =
    if loggingNodes == [] then
      [ { url = "http://127.0.0.1:3100/loki/api/v1/push"; } ]
    else
      map (x: { url = "http://${x.host.address}:3100/loki/api/v1/push"; }) loggingNodes;
in
{
  services.promtail = {
    enable = true;

    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };

      positions.filename = "/var/lib/promtail/positions.yaml";

      clients = lokiClients;

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = { job = "systemd-journal"; };
          };
          relabel_configs = [
            { source_labels = [ "__journal__systemd_unit" ]; target_label = "unit"; }
          ];
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/promtail 0750 promtail promtail - -"
  ];

  systemd.services.promtail = (lib.mkMerge [
    { }
    (lib.mkIf (loggingNodes == []) {
      after = [ "loki.service" ];
      wants = [ "loki.service" ];
    })
  ]);
}

