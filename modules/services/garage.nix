{ config, ... }:

{
  services.garage = {
    enable = true;
    environmentFile = config.sops.secrets."garage/env".path;
    settings = {
      data_dir = "/var/lib/garage/data";
      metadata_dir = "/var/lib/garage/meta";
      replication_factor = 1;
      rpc = {
        rpc_bind_addr = "0.0.0.0:3901";
        rpc_secret = "$GARAGE_RPC_SECRET";
      };
      s3_api = {
        api_bind_addr = "0.0.0.0:3900";
      };
      admin = {
        api_bind_addr = "0.0.0.0:3903";
      };
    };
  };

  sops.secrets."garage/env" = {};
}
