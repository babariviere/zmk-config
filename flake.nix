{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        {
          inputs',
          lib,
          pkgs,
          ...
        }:
        {
          packages = rec {
            default = inputs'.nixpkgs.legacyPackages.linkFarm "zmk-config-default" [
              {
                name = "sweep";
                path = sweep;
              }
            ];

            sweep = inputs'.zmk-nix.legacyPackages.buildSplitKeyboard {
              name = "firmware";

              src = inputs.nixpkgs.lib.sourceFilesBySuffices self [
                "sweep.conf"
                "sweep.keymap"
                ".yml"
              ];

              board = "nice_nano_v2";
              shield = "lotus58_%PART%";

              zephyrDepsHash = "sha256-Afxy2Dt3dUnkK+K4evsjyEIHI+sWVbJIWQ826p74SMo=";

              meta = {
                description = "sweep firmware";
                license = inputs.nixpkgs.lib.licenses.mit;
                platforms = inputs.nixpkgs.lib.platforms.all;
              };
            };

            update = inputs'.zmk-nix.packages.update;
          };

          devShells = {
            default = inputs'.zmk-nix.devShells.default;
          };
        };
    };
}
