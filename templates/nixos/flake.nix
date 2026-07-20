{
  description = "Install igor-semyonov/nvim system-wide via NixOS, customized";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    mynvim.url = "github:igor-semyonov/nvim";
    mynvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    mynvim,
    ...
  }: {
    # Adjust "myhost" and system to match your setup.
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        mynvim.nixosModules.default
        (
          {...}: {
            # Enable and customize neovim. Everything defaults to enabled.
            wrappers.neovim.enable = true;
            wrappers.neovim.languages.matlab.enable = false;
            wrappers.neovim.languages.latex.enable = false;

            # ...plus the rest of your NixOS config (boot, fileSystems, etc.)
            system.stateVersion = "24.11";
          }
        )
      ];
    };
  };
}
