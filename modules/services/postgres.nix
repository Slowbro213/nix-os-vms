{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    settings = {
      shared_buffers = "256MB";
    };
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    port = 9187;
    dataSourceName = "postgresql:///postgres?host=/run/postgresql&user=postgres";
  };
}
