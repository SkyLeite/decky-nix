{ config, pkgs, lib, poetry2nix }:
let
  pythonPackages =
    pkgs.poetry2nix.mkPoetryPackages { projectDir = config.pythonSource; };

  packages = builtins.concatStringsSep " "
    (map (x: toString x) pythonPackages.poetryPackages);
  foo = builtins.trace packages "";
in pkgs.stdenv.mkDerivation {
  name = config.name;
  version = config.version;
  src = config.src;

  buildInputs = [ ] ++ config.jsLibs;

  buildPhase = builtins.trace foo ''
    echo lmao
    echo 1 > foo.txt
  '';

  installPhase = ''
    mkdir -p $out/vendor
    cp ${packages} -t $out/vendor -r
  '';
}
