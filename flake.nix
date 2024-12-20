{
  description = "A NixOS module for running ephemeral, tmpfs-based Bitcoin Core Cirrus CI runners in QEMU VMs using a shared cache";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      nixos-lib = import (nixpkgs + "/nixos/lib") { lib = nixpkgs.lib; };
      mkTest =
        imports: system:
        nixos-lib.runTest {
          inherit imports;
          hostPkgs = import nixpkgs { inherit system; };
        };
    in
    {
      nixosModules.default = import ./module.nix;

      checks = forAllSystems (system: {
        basic = mkTest [ ./tests/basic.nix ] system;
      });

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
