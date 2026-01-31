{ config, ... }:

{
  services.grafana = {
    enable = true;
    environmentFile = config.sops.secrets."grafana/env".path;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "localhost";
        root_url = "%(protocol)s://%(domain)s/";
      };
      security = {
        admin_user = "admin";
        admin_password = "$GRAFANA_ADMIN_PASSWORD";
      };
    };
  };

  sops.secrets."grafana/env" = {};
}
