{ config, pkgs, ... }:

{
  sops.secrets."garage/rpc_secret"    = { owner = "garage"; group = "garage"; mode = "0400"; };
  sops.secrets."garage/admin_token"   = { owner = "garage"; group = "garage"; mode = "0400"; };
  sops.secrets."garage/metrics_token" = { owner = "garage"; group = "garage"; mode = "0400"; };


  environment.etc."garage/garage.toml".text = ''
    metadata_dir = "/var/lib/garage/meta"
    data_dir = "/var/lib/garage/data"
    db_engine = "lmdb"
    replication_factor = 1

    rpc_bind_addr = "127.0.0.1:3901"
    rpc_public_addr = "127.0.0.1:3901"

    [s3_api]
    s3_region = "garage"
    api_bind_addr = "127.0.0.1:3900"

    [admin]
    api_bind_addr = "127.0.0.1:3903"
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
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

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

