# nix-os-vms

This repository defines NixOS VM/host configurations using flakes, disko for disk
layout, and sops-nix for secrets. It also includes a small framework for
managing backend services via a custom `services.backends` module.

## Repository layout

- `flake.nix`: Flake inputs and outputs, including host definitions and
  convenience `deploy-all` / `install-all` apps. The deploy script provisions the
  sops-nix key and runs `nixos-rebuild` on each host in the inventory.
- `hosts/`: Per-host NixOS configurations.
  - `inventory.nix` declares host metadata (system, address, ssh user).
  - `test-vm.nix` composes base modules, disko, sops-nix, and backend services.
- `modules/`: Reusable NixOS modules.
  - `base.nix` sets common packages and SSH/Prometheus settings.
  - `secrets.nix` configures sops-nix defaults.
  - `backends.nix` defines the `services.backends` option and systemd wiring.
  - `backends/` contains concrete backend service definitions.
  - `services/` contains infrastructure service modules (database, cache, logs, metrics, proxy).
- `disko/`: Disk layout declarations for disko.
- `secrets.yaml`: Encrypted secrets managed by sops-nix.

## Usage

### Deploy all hosts

```sh
nix run .#deploy-all
```

You can target a single host by setting `ONLY_HOST`:

```sh
ONLY_HOST=test-vm nix run .#deploy-all
```

### Install all hosts (nixos-anywhere)

```sh
nix run .#install-all
```

### Adding a new host

1. Add a host entry to `hosts/inventory.nix`.
2. Create `hosts/<name>.nix` to import the shared modules you need.
3. If required, add a disk layout in `disko/` and a backend module under
   `modules/backends/`.

## Secrets

sops-nix expects an age key at `/var/lib/sops-nix/key.txt`. The `deploy-all`
script provisions it before switching the host configuration. Secrets live in
`secrets.yaml` and can be referenced by backend services via
`environmentFileSecret`.
