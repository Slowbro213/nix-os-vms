{ lib, config, pkgs, ... }:

let
  inherit (lib)
    mkOption mkEnableOption types mkIf mkMerge
    mapAttrs' nameValuePair mapAttrsToList optionalAttrs;

  cfg = config.services.backends;
in
{
  options.services.backends = mkOption {
    description = "Declarative backend services.";
    default = {};
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "backend service ${name}";

        package = mkOption {
          type = types.package;
          description = "Derivation that provides the backend executable.";
        };

        execStart = mkOption {
          type = types.str;
          description = "systemd ExecStart command.";
        };

        args = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Extra CLI args appended to execStart (space-separated).";
        };

        environmentFileSecret = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            If set, use this sops-nix secret key as EnvironmentFile and restart
            the service when the secret changes (e.g. "${name}/env").
          '';
        };

        wantedBy = mkOption { type = types.listOf types.str; default = [ "multi-user.target" ]; };
        after    = mkOption { type = types.listOf types.str; default = [ "network-online.target" ]; };
        wants    = mkOption { type = types.listOf types.str; default = [ "network-online.target" ]; };

        restart = mkOption { type = types.str; default = "on-failure"; };
        dynamicUser = mkOption { type = types.bool; default = true; };
      };
    }));
  };

  config = mkMerge [
    {
      systemd.services = mapAttrs' (name: b:
        nameValuePair name (mkIf b.enable {
          description = "Backend: ${name}";
          wantedBy = b.wantedBy;
          after = b.after;
          wants = b.wants;

          restartTriggers =
            lib.optionals (b.environmentFileSecret != null) [
              config.sops.secrets.${b.environmentFileSecret}.path
            ];

          serviceConfig = mkMerge [
            {
              ExecStart =
                if b.args == []
                then b.execStart
                else "${b.execStart} ${lib.escapeShellArgs b.args}";

              Restart = b.restart;
              DynamicUser = b.dynamicUser;
            }
            (mkIf (b.environmentFileSecret != null) {
              EnvironmentFile = config.sops.secrets.${b.environmentFileSecret}.path;
            })
          ];
        })
      ) cfg;
    }

    (mkIf (config ? sops) {
      sops.secrets = mkMerge (mapAttrsToList (name: b:
        mkIf (b.enable && b.environmentFileSecret != null) {
          ${b.environmentFileSecret} = {
            owner = "root";
            mode = "0400";
            restartUnits = [ "${name}.service" ];
          };
        }
      ) cfg);
    })
  ];
}

