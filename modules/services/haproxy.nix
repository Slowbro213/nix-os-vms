{ config, lib, ... }:

{
  services.haproxy = {
    enable = true;

    config = ''
      global
        log /dev/log local0
        maxconn 10000

      defaults
        log global
        mode http
        option httplog
        timeout connect 5s
        timeout client  60s
        timeout server  60s

      frontend fe_http
        bind 0.0.0.0:80
        # If you also want IPv6:
        # bind :::80

        # Route by Host header
        acl host_grafana    hdr(host) -i grafana.test-vm
        acl host_prometheus hdr(host) -i prometheus.test-vm
        acl host_loki       hdr(host) -i loki.test-vm
        acl host_garage     hdr(host) -i garage.test-vm
        acl host_backend    hdr(host) -i backend.test-vm

        use_backend be_grafana    if host_grafana
        use_backend be_prometheus if host_prometheus
        use_backend be_loki       if host_loki
        use_backend be_garage     if host_garage
        use_backend be_backend    if host_backend

        # Default: send to Grafana (or pick what you want)
        default_backend be_grafana

      backend be_grafana
        server s1 127.0.0.1:3000 check

      backend be_prometheus
        server s1 127.0.0.1:9090 check

      backend be_loki
        server s1 127.0.0.1:3100 check

      # Garage S3 API (HTTP)
      backend be_garage
        server s1 127.0.0.1:3900 check

      backend be_backend
        server s1 127.0.0.1:8080 check
    '';
  };

  systemd.services.haproxy.after = [ "network-online.target" ];
  systemd.services.haproxy.wants = [ "network-online.target" ];
}

