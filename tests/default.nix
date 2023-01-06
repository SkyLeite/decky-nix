{ pkgs, lib }:
let
  out = lib.mkPlugin {
    meta = {
      name = "test plugin";
      version = "1";
      author = "Sky Leite";
      description = "Doesn't really do much yet";
    };

    pythonSource = ./demo;
    frontendPath = ./demo-front;
  };
in pkgs.runCommand "devTest" { } ''
  mkdir -p $out
  # cmp ${out}/foo.txt actual
  cp -a ${out}/. $out
''
