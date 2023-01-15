{ pkgs }:
let
  nodeDependencies =
    (pkgs.callPackage ./node-packages.nix { }).nodeDependencies;

  script = ''
    require('dotenv').config()
    const plugin = require("../plugin.json");
    const CDP = require('chrome-remote-interface');

    const options = {
      host: process.env.DECKIP,
      port: 8081,
    };

    async function main() {
        let client;
        try {
            // connect to endpoint
            client = await CDP({...options,
                target: (targets) => targets.find((target) => target.title == "Steam"),
            });

            // extract domains
            const {Network, Page, Runtime} = client;

          await Runtime.evaluate({ expression: `console.log("Reloading ${plugin.name} from an unbelievably stupid dev script")` });
          await Runtime.evaluate({ expression: `importDeckyPlugin("${plugin.name}")` });
        } catch (err) {
            console.error(err);
        } finally {
            if (client) {
                await client.close();
            }
        }
    }

    main();
  '';

  run = pkgs.writeShellScript "run" ''
    ${pkgs.node}/bin/node ${script}
  '';
in pkgs.stdenv.mkDerivation {
  name = config.meta.name;
  version = config.meta.version;

  dontUnpack = true;

  buildInputs = [ pkgs.nodejs ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${run} $out/bin/run
  '';
}
