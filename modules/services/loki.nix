{ config, lib, ... }:

{
  sops.secrets."loki/s3" = { owner = "loki"; mode = "0400"; };

  services.loki = {
    enable = true;

    extraFlags = [ "-config.expand-env=true" ];

    configuration = {
      auth_enabled = false;

      server.http_listen_port = 3100;

      common = {
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
      };

      schema_config.configs = [
        {
          from = "2025-01-01";
          store = "tsdb";
          object_store = "s3";
          schema = "v13";
          index = { prefix = "index_"; period = "24h"; };
        }
      ];

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/index";
          cache_location = "/var/lib/loki/index_cache";
        };

        aws = {
          s3 = "$LOKI_S3_URI";
          s3forcepathstyle = true;
        };
      };
    };
  };

  systemd.services.loki.serviceConfig.EnvironmentFile =
    config.sops.secrets."loki/s3".path;

  systemd.services.loki.after = [ "garage.service" ];
  systemd.services.loki.wants = [ "garage.service" ];

  networking.firewall.allowedTCPPorts = [ 3100 ];
}

