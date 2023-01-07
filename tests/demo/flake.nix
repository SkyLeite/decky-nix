{
  inputs.decky.url = "github:SkyLeite/decky-nix";

  outputs = { self, nixpkgs, decky }: {
    plugins.x86_64-linux.default =
      builtins.trace decky.lib decky.lib.x86_64-linux.mkPlugin {
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
