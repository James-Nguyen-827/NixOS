# NixOS build and deployment justfile

# Variables
user := "james"
local_ip := "192.168.1.67"

# Build the NixOS configuration
build:
    nix build .#nixosConfigurations.default.config.system.build.toplevel

# Deploy the configuration to the target host
deploy:
    ssh {{user}}@{{local_ip}} "sudo nixos-rebuild switch --flake github:James-Nguyen-827/NixOS#default"
