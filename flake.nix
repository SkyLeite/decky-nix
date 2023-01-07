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
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, poetry2nix }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in rec {
      lib = (import ./lib { inherit pkgs poetry2nix; });
      checks.x86_64-linux.default = (import ./tests { inherit pkgs lib; });
    };
}
