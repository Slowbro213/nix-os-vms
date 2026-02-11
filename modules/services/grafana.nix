{ ... }:

{
  services.grafana = {
    enable = true;

    settings.server = {
      http_port = 3000;
      http_addr = "0.0.0.0";
    };

    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          access = "proxy";
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://127.0.0.1:3100";
          access = "proxy";
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}

