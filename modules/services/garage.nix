{ config, pkgs, hostMeta, ... }:

{
  sops.secrets."garage/rpc_secret"    = { owner = "garage"; group = "garage"; mode = "0400"; };
  sops.secrets."garage/admin_token"   = { owner = "garage"; group = "garage"; mode = "0400"; };
  sops.secrets."garage/metrics_token" = { owner = "garage"; group = "garage"; mode = "0400"; };


  environment.etc."garage/garage.toml".text = ''
    metadata_dir = "/var/lib/garage/meta"
    data_dir = "/var/lib/garage/data"
    db_engine = "fjall"
    metadata_auto_snapshot_interval = "6h"

    replication_factor = 2

    compression_level = 2

    rpc_bind_addr = "[::]:3901"
    rpc_public_addr = "${hostMeta.address}:3901"

    [s3_api]
    s3_region = "garage"
    api_bind_addr = "[::]:3900"
    root_domain = ".s3.garage"

    [admin]
    api_bind_addr = "127.0.0.1:3903"

    [s3_web]
    bind_addr = "[::]:3902"
    root_domain = ".web.garage"
    index = "index.html"

    [consul_discovery]
    api = "agent"
    consul_http_addr = "http://127.0.0.1:8500"

    # tls_skip_verify = false

    service_name = "garage-daemon"
    datacenters = ["dc1","dc2","dc3"]
  '';

  users.users.garage = { isSystemUser = true; group = "garage"; };
  users.groups.garage = {};

  systemd.tmpfiles.rules = [
    "d /var/lib/garage 0750 garage garage - -"
    "d /var/lib/garage/meta 0750 garage garage - -"
    "d /var/lib/garage/data 0750 garage garage - -"
  ];

  systemd.services.garage = {
    description = "Garage object storage";
    wantedBy = [ "multi-user.target" ];

    after = [ "network-online.target" "consul.service" ];
    wants = [ "network-online.target" "consul.service" ];

    serviceConfig = {
      ExecStart = "${pkgs.garage}/bin/garage -c /etc/garage/garage.toml server";
      Restart = "on-failure";

      Environment = [
        "GARAGE_RPC_SECRET_FILE=${config.sops.secrets."garage/rpc_secret".path}"
        "GARAGE_ADMIN_TOKEN_FILE=${config.sops.secrets."garage/admin_token".path}"
        "GARAGE_METRICS_TOKEN_FILE=${config.sops.secrets."garage/metrics_token".path}"
      ];

      User = "garage";
      Group = "garage";

      UMask = "0027";
    };
  };
}

