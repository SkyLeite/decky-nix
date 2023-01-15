{ config, pkgs, poetry2nix }:
let
  pythonPackages =
    pkgs.poetry2nix.mkPoetryPackages { projectDir = config.python.src; };

  packages = builtins.concatStringsSep " "
    (map (x: toString x) pythonPackages.poetryPackages);

  pythonSourceDirName = builtins.baseNameOf config.python.src;

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
        directories = [[\"./\"], [\"lib\"], [\"vendor\"], [\"default\"], [\"default/lib\"], [\"default/vendor\"], [\"/usr/lib/python3.10\"]]
        for dir in directories:
            sys.path.append(str(plugin_dir.joinpath(*dir)))

    add_plugin_to_path()

    from lib import *

    dir()
  '';

  frontend = pkgs.buildNpmPackage (pkgs.lib.recursiveUpdate config.frontend {
    name = config.meta.name;
    version = config.meta.version;
  });

  frontendDirName =
    config.frontend.name or (builtins.baseNameOf config.frontend.src);
in pkgs.stdenv.mkDerivation {
  name = config.meta.name;
  version = config.meta.version;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/default/lib

    # Vendor Python packages
    mkdir -p $out/default/vendor

    find ${packages} -type d -name "site-packages" -exec cp -r {}/. $out/default/vendor \;
    # cp ${packages}/. -t $out/default/vendor -r

    # Copy Python source code and import it on main.py
    cp ${config.python.src}/${pythonSourceDirName}/. -t $out/default/lib/ -a

    printf "${mainPythonFile}" > $out/main.py

    # Write plugin.json
    cp ${pluginJson} $out/plugin.json

    # Write frontend
    mkdir -p $out/dist
    cp ${frontend}/lib/node_modules/${frontendDirName}/build/. -t $out/dist -a
  '';
}
