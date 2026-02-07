{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    
    #secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    #backends
    test-backend-main.url = "github:Slowbro213/c-backend?ref=main";
    test-backend-main.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs:
  let
    lib = nixpkgs.lib;

    inventory = import ./hosts/inventory.nix;

    mkHost = name: hostMeta:
      lib.nixosSystem {
        system = hostMeta.system;
        specialArgs = { inherit inputs hostMeta; };
        modules = [
          # allow only consul (unfree)
          ({ lib, ... }: {
            nixpkgs.config.allowUnfreePredicate = pkg:
              builtins.elem (lib.getName pkg) [ "consul" ];
          })

          ./hosts/${name}.nix
        ];
      };


    # This is the system you run `nix run`
    controlSystem = "x86_64-linux";
    pkgs = import nixpkgs { system = controlSystem; };

    deployAllScript = pkgs.writeShellScript "deploy-all" ''
      set -euo pipefail

      ONLY_HOST="''${ONLY_HOST:-}"

      deploy_one() {
        local name="$1"
        local user="$2"
        local addr="$3"

        if [ -n "$ONLY_HOST" ] && [ "$name" != "$ONLY_HOST" ]; then
          return 0
        fi

        echo "==> Deploy $name -> $user@$addr"
        ssh "$user@$addr" 'install -d -m 0700 /var/lib/sops-nix'
        scp /var/lib/sops-nix/key.txt "$user@$addr:/var/lib/sops-nix/key.txt"
        ssh "$user@$addr" 'chmod 0600 /var/lib/sops-nix/key.txt && chown root:root /var/lib/sops-nix/key.txt'

        nixos-rebuild switch \
          --flake ${self}#"$name" \
          --target-host "$user@$addr" \
          "''${@:4}"
      }

      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: host: ''
        deploy_one ${lib.escapeShellArg name} \
                  ${lib.escapeShellArg host.sshUser} \
                  ${lib.escapeShellArg host.address}
      '') inventory)}

      echo "==> Done"
    '';

    installAllScript = pkgs.writeShellScript "install-all" ''
      set -euo pipefail

      ONLY_HOST="''${ONLY_HOST:-}"

      install_one() {
        local name="$1"
        local user="$2"
        local addr="$3"

        if [ -n "$ONLY_HOST" ] && [ "$name" != "$ONLY_HOST" ]; then
          return 0
        fi

        echo "==> Install $name -> $user@$addr"
        nix run github:nix-community/nixos-anywhere -- \
          -f ${self}#"$name" \
          "$user@$addr" \
          "''${@:4}"
      }

      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: host: ''
        install_one ${lib.escapeShellArg name} \
                   ${lib.escapeShellArg host.sshUser} \
                   ${lib.escapeShellArg host.address}
      '') inventory)}

      echo "==> Done"
    '';

  in
  {
    nixosConfigurations = lib.mapAttrs mkHost inventory;

    apps.${controlSystem} = {
      default = { type = "app"; program = toString deployAllScript; };

      deploy-all = { type = "app"; program = toString deployAllScript; };
      install-all = { type = "app"; program = toString installAllScript; };
    };
  };
}

