{ config, lib, ... }:

let
  backendServices = lib.filterAttrs (_: backend: backend.enable && backend.exposePort != null)
    config.services.backends;

  backendAcls = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: backend: ''
    acl is_backend_${name} path_beg /backends/${name}
    http-request set-path %[path,regsub(^/backends/${name},/)] if is_backend_${name}
    use_backend backend_${name} if is_backend_${name}
  '') backendServices);

  backendServers = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: backend: ''
  backend backend_${name}
    server ${name} 127.0.0.1:${toString backend.exposePort}
  '') backendServices);

  staticServices = {
    garage = 3900;
    attic = 8081;
    typesense = 8108;
    grafana = 3000;
    prometheus = 9090;
    loki = 3100;
  };

  staticAcls = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: port: ''
    acl is_${name} path_beg /${name}
    http-request set-path %[path,regsub(^/${name},/)] if is_${name}
    use_backend ${name} if is_${name}
  '') staticServices);

  staticBackends = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: port: ''
  backend ${name}
    server ${name} 127.0.0.1:${toString port}
  '') staticServices);

in
{
  services.haproxy = {
    enable = true;
    config = ''
      global
        log /dev/log local0
        maxconn 4096

      defaults
        log global
        mode http
        option httplog
        timeout connect 10s
        timeout client 1m
        timeout server 1m

      frontend http-in
        bind 0.0.0.0:80
        ${staticAcls}
        ${backendAcls}
        default_backend grafana

      ${staticBackends}
      ${backendServers}
    '';
  };
}
