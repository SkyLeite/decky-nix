{ pkgs, lib }:
let
  plugin = lib.mkPlugin {
    meta = {
      name = "test plugin";
      version = "1";
      author = "Sky Leite";
      description = "Doesn't really do much yet";
    };

    frontend = {
      src = ./demo/frontend;
      npmDepsHash = "sha256-hi9TKcKXhfeceW2iaIIV6HbNxZv72bZ7mhR0K9QS1hI=";
    };

    python = { src = ./demo/backend; };
  };
in pkgs.runCommand "devTest" { } ''
  mkdir -p $out
  cp -a ${plugin}/. $out
''
