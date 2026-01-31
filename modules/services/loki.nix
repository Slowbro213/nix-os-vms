{ config, ... }:

{
  services.loki = {
    enable = true;
    environmentFile = config.sops.secrets."loki/env".path;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
      };
      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = { store = "inmemory"; };
            replication_factor = 1;
          };
        };
      };
      schema_config = {
        configs = [
          {
            from = "2024-01-01";
            store = "boltdb-shipper";
            object_store = "s3";
            schema = "v12";
            index = {
              prefix = "loki_index_";
              period = "24h";
            };
          }
        ];
      };
      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/index";
          cache_location = "/var/lib/loki/cache";
        };
        aws = {
          s3 = "http://127.0.0.1:3900";
          bucketnames = "loki";
          region = "garage";
          access_key_id = "$GARAGE_ACCESS_KEY_ID";
          secret_access_key = "$GARAGE_SECRET_ACCESS_KEY";
          s3forcepathstyle = true;
        };
      };
    };
  };

  sops.secrets."loki/env" = {};
}
