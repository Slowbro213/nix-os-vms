{ config, pkgs, lib, hostMeta, inventory, ... }:

let
  coordinator = "vm-1";
  isCoordinator = config.networking.hostName == coordinator;

  clusterHosts = [ "vm-1" "vm-2" "vm-3" ];

  clusterInventory =
    lib.filterAttrs (name: _meta: builtins.elem name clusterHosts) inventory;

  desired = lib.mapAttrs' (_name: m:
    lib.nameValuePair "${m.address}:3901" { zone = m.zone; capacity = m.capacity; }
  ) clusterInventory;

in {
  environment.etc."garage/layout.json".text = builtins.toJSON desired;
  systemd.services.garage-layout = lib.mkIf isCoordinator {
    description = "Apply Garage layout from declarative inventory";
    wantedBy = [];
    after = [ "garage.service" ];
    requires = [ "garage.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "garage";
      Group = "garage";

      Environment = [
        "GARAGE_RPC_SECRET_FILE=${config.sops.secrets."garage/rpc_secret".path}"
        "GARAGE_ADMIN_TOKEN_FILE=${config.sops.secrets."garage/admin_token".path}"
      ];

      ExecStart = pkgs.writeShellScript "garage-apply-layout" ''
        set -euo pipefail

        GARAGE="${pkgs.garage}/bin/garage -c /etc/garage/garage.toml"
        DESIRED=/etc/garage/layout.json

        for i in $(seq 1 60); do
          if $GARAGE status >/dev/null 2>&1; then break; fi
          sleep 2
        done

        STATUS="$($GARAGE status)"

        ${pkgs.jq}/bin/jq -r 'to_entries[] | "\(.key) \(.value.zone) \(.value.capacity)"' "$DESIRED" \
        | while read -r addr zone cap; do
            line="$(printf "%s\n" "$STATUS" | grep -F "$addr" || true)"
            [ -n "$line" ] || { echo "addr $addr not found in cluster status yet"; exit 1; }

            nodeid="$(echo "$line" | grep -Eo '^[0-9a-f]{16}' | head -n1)"
            [ -n "$nodeid" ] || { echo "could not parse node id from: $line"; exit 1; }

            echo "Assign $nodeid: zone=$zone cap=$cap (addr=$addr)"
            $GARAGE layout assign -z "$zone" -c "$cap" "$nodeid"
          done

        SHOW="$($GARAGE layout show)"
        CUR="$(echo "$SHOW" | grep -Ei 'version' | grep -Eo '[0-9]+' | head -n1 || true)"
        CUR="''${CUR:-0}"
        NEXT=$((CUR + 1))

        echo "Apply layout version $NEXT"
        $GARAGE layout apply --version "$NEXT"
      '';
        Restart = "on-failure";
        RestartSec = "15s";
    };
  };

  systemd.timers.garage-layout = lib.mkIf isCoordinator {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "30s";
      Unit = "garage-layout.service";
    };
  };
}

