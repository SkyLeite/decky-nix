{ config, pkgs, lib, poetry2nix }:
let
  pythonPackages =
    pkgs.poetry2nix.mkPoetryPackages { projectDir = config.pythonSource; };

  packages = builtins.concatStringsSep " "
    (map (x: toString x) pythonPackages.poetryPackages);

  pythonSourceDirName = builtins.baseNameOf config.pythonSource;

  mainPythonFile = ''
    # From https://github.com/FrogTheFrog/moondeck/commit/c062ff90de23c0641ae2ca79f32f3f545d4a69af
    def get_plugin_dir():
        from pathlib import Path

        return Path(__file__).parent.resolve()

    def add_plugin_to_path():
        import sys

        plugin_dir = get_plugin_dir()
        directories = [["./"], ["lib"], ["vendor"]]
        for dir in directories:
            sys.path.append(str(plugin_dir.joinpath(*dir)))

    add_plugin_to_path()

    import lib
  '';
in pkgs.stdenv.mkDerivation {
  name = config.name;
  version = config.version;
  src = config.src;

  buildInputs = [ ] ++ config.jsLibs;

  buildPhase = builtins.trace config.pythonSource ''
    echo lmao
    echo 1 > foo.txt
  '';

  installPhase = ''
    mkdir -p $out/default/lib

    # Vendor Python packages
    mkdir -p $out/default/vendor
    cp ${packages} -t $out/default/vendor -r

    # Copy Python source code and import it on main.py
    cp ${config.pythonSource}/${pythonSourceDirName}/. -t $out/default/lib/ -a

    printf "${mainPythonFile}" > $out/main.py
  '';
}
