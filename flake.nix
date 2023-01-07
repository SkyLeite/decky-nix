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
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      lib = (import ./lib { inherit pkgs poetry2nix; });

      checks.x86_64-linux.test = (import ./tests {
        inherit pkgs;

        plugin = demoPlugin.plugins.default;
      });
    };
}
