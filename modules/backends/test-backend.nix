{ inputs, pkgs, ... }:

let
  pkg = inputs.test-backend-main.packages.${pkgs.stdenv.hostPlatform.system}.c-backend;
in
{
  services.backends.test-backend-main = {
    enable = true;
    package = pkg;
    execStart = "${pkg}/bin/c-backend";
    args = [ "8080" "1" ];
    environmentFileSecret = "test-backend/env";
    exposePort = 8080;
    metricsPort = 8080;
    memoryMax = "512M";
    cpuQuota = "50%";
  };
}
