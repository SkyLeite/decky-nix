{
  description = "Nix library for writing Decky plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "github:DavHau/mach-nix";
    mach-nix.inputs.nixpkgs.follows = "nixpkgs";

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    demoPlugin.url = "./tests/demo";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, poetry2nix, demoPlugin }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        lib = (import ./lib { inherit pkgs lib poetry2nix; });
        checks = flake-utils.lib.flattenTree {
          test = (import ./tests {
            inherit pkgs lib;
            plugin = demoPlugin.plugins.x86_64-linux.default;
          });
        };
      });
}
