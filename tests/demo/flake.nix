{
  inputs.decky.url = "github:SkyLeite/decky-nix";

  outputs = { self, nixpkgs, decky }: {
    plugins.default = decky.lib.mkPlugin {
      meta = {
        name = "test plugin";
        version = "1";
        author = "Sky Leite";
        description = "Doesn't really do much yet";
      };

      pythonSource = ./backend;
      frontendSource = ./frontend;
    };
  };
}
