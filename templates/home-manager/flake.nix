{
  description = "Install igor-semyonov/nvim via home-manager, customized";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mynvim.url = "github:igor-semyonov/nvim";
    mynvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, mynvim, ... }:
    {
      # Adjust "user@host" and system to match your setup.
      homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          mynvim.homeModules.default
          (
            { ... }:
            {
              home.username = "user";
              home.homeDirectory = "/home/user";
              home.stateVersion = "24.11";

              # Enable and customize neovim. Everything defaults to enabled.
              wrappers.neovim.enable = true;
              wrappers.neovim.languages.latex.enable = false;
              wrappers.neovim.groups.web.enable = false; # drop the web set
              wrappers.neovim.languages.json.enable = true; # ...keep JSON
              # Or: disableAll = true; then enable only what you want.
            }
          )
        ];
      };
    };
}
