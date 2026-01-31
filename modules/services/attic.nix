{ config, ... }:

{
  services.attic = {
    enable = true;
    environmentFile = config.sops.secrets."attic/env".path;
    settings = {
      listen = "0.0.0.0:8081";
      chunkSize = 1048576;
      storage = {
        type = "s3";
        bucket = "attic";
        region = "garage";
        endpoint = "http://127.0.0.1:3900";
        access_key_id = "$GARAGE_ACCESS_KEY_ID";
        secret_access_key = "$GARAGE_SECRET_ACCESS_KEY";
      };
    };
  };

  sops.secrets."attic/env" = {};
}
