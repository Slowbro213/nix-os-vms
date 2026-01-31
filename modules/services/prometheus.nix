{ config, lib, ... }:

let
  backendScrapeConfigs = lib.flatten (lib.mapAttrsToList (name: backend:
    lib.optional (backend.metricsPort != null) {
      job_name = "backend-${name}";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString backend.metricsPort}" ];
        }
      ];
    }
  ) config.services.backends);
in
{
  services.prometheus = {
    enable = true;
    port = 9090;
    globalConfig = {
      scrape_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
      }
      {
        job_name = "postgres";
        static_configs = [ { targets = [ "127.0.0.1:9187" ]; } ];
      }
      {
        job_name = "redis";
        static_configs = [ { targets = [ "127.0.0.1:9121" ]; } ];
      }
      {
        job_name = "garage";
        static_configs = [ { targets = [ "127.0.0.1:3903" ]; } ];
      }
      {
        job_name = "attic";
        metrics_path = "/metrics";
        static_configs = [ { targets = [ "127.0.0.1:8081" ]; } ];
      }
      {
        job_name = "typesense";
        metrics_path = "/metrics";
        static_configs = [ { targets = [ "127.0.0.1:8108" ]; } ];
      }
      {
        job_name = "loki";
        static_configs = [ { targets = [ "127.0.0.1:3100" ]; } ];
      }
      {
        job_name = "promtail";
        static_configs = [ { targets = [ "127.0.0.1:9080" ]; } ];
      }
      {
        job_name = "grafana";
        metrics_path = "/metrics";
        static_configs = [ { targets = [ "127.0.0.1:3000" ]; } ];
      }
      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "127.0.0.1:9090" ]; } ];
      }
    ] ++ backendScrapeConfigs;
  };
}
