{ pkgs, lib }:
let
  out = lib.mkPlugin {
    name = "test plugin";
    version = "1";
    src = ./.;
    pythonSource = ./demo;

    jsLibs = [ ];
  };
in pkgs.runCommand "devTest" { } ''
  mkdir -p $out
  cmp ${out}/foo.txt actual
  cp -r ${out} $out
''
