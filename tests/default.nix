{ pkgs, lib }:
let
  out = lib.mkPlugin {
    meta = {
      name = "test plugin";
      author = "Sky Leite";
      description = "Doesn't really do much yet";
    };

    name = "test plugin";
    version = "1";
    src = ./.;
    pythonSource = ./demo;

    jsLibs = [ ];
  };
in pkgs.runCommand "devTest" { } ''
  mkdir -p $out
  # cmp ${out}/foo.txt actual
  cp -a ${out}/. $out
''
