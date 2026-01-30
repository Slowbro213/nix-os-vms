{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ git vim ];

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    port = 9100;
    enabledCollectors = [ "systemd" ];
  };
}


