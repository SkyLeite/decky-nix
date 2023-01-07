{ pkgs, plugin }:
pkgs.runCommand "devTest" { } ''
  mkdir -p $out
  cp -a ${plugin}/. $out
''
