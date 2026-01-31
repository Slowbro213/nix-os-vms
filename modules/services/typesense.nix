{ config, ... }:

{
  services.typesense = {
    enable = true;
    environmentFile = config.sops.secrets."typesense/env".path;
    settings = {
      api_key = "$TYPESENSE_API_KEY";
      listen_port = 8108;
    };
  };

  sops.secrets."typesense/env" = {};
}
