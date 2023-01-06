{ pkgs, lib, poetry2nix }: {
  mkPlugin = config:
    import ./mkPlugin.nix { inherit config pkgs lib poetry2nix; };
}
