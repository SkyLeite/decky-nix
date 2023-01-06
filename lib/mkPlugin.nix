{ config, pkgs, lib, poetry2nix }:
let
  pythonPackages =
    pkgs.poetry2nix.mkPoetryPackages { projectDir = config.pythonSource; };

  packages = builtins.concatStringsSep " "
    (map (x: toString x) pythonPackages.poetryPackages);

  pythonSourceDirName = builtins.baseNameOf config.pythonSource;

  pluginJson = builtins.toFile "input.json" (builtins.toJSON {
    name = config.meta.name;
    author = config.meta.author;
    flags = config.meta.flags or [ ];
    publish = {
      tags = config.meta.tags or [ ];
      description = config.meta.description;
      image = config.image or null;
    };
  });

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

  frontend = pkgs.buildNpmPackage {
    name = config.meta.name;
    version = config.meta.version;

    src = config.frontendSource;
    npmDepsHash = "sha256-hi9TKcKXhfeceW2iaIIV6HbNxZv72bZ7mhR0K9QS1hI=";
  };

  frontendDirName = builtins.baseNameOf config.frontendSource;

in pkgs.stdenv.mkDerivation {
  name = config.meta.name;
  version = config.meta.version;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/default/lib

    # Vendor Python packages
    mkdir -p $out/default/vendor
    cp ${packages} -t $out/default/vendor -r

    # Copy Python source code and import it on main.py
    cp ${config.pythonSource}/${pythonSourceDirName}/. -t $out/default/lib/ -a

    printf "${mainPythonFile}" > $out/main.py

    # Write plugin.json
    cp ${pluginJson} $out/plugin.json

    # Write frontend
    mkdir -p $out/dist
    cp ${frontend}/lib/node_modules/${frontendDirName}/build/. -t $out/dist -a
  '';
}
