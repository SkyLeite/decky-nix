{ pkgs, poetry2nix }: {
  mkPlugin = config: import ./mkPlugin.nix { inherit config pkgs poetry2nix; };
}
