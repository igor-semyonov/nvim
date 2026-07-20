{
  description = "A Lua-natic's neovim flake, built with nix-wrapper-modules + flake-parts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # `nix fmt` / formatting check, wired in as a flake-parts module below.
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Recursively imports ./modules/** into the neovim wrapper module, so each
    # language/group/tool lives in its own file (drop a file = add a language).
    import-tree.url = "github:vic/import-tree";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # To pull a plugin that isn't in nixpkgs, add it here named `plugins-<name>`
    # and reference it in module.nix via `config.nvim-lib.neovimPlugins.<name>`:
    # plugins-foo = { url = "github:owner/foo"; flake = false; };
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    flake-parts,
    treefmt-nix,
    ...
  } @ inputs: let
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        wrappers.flakeModules.wrappers
        treefmt-nix.flakeModule
      ];
      systems = nixpkgs.lib.platforms.all;

      flake = let
        installModule = wrappers.lib.getInstallModule {
          name = "neovim";
          value = module;
        };
      in {
        wrappers.neovim = module;
        nixosModules = {
          default = self.nixosModules.neovim;
          neovim = installModule;
        };
        homeModules = {
          default = self.homeModules.neovim;
          neovim = installModule;
        };
        overlays = {
          default = self.overlays.neovim;
          neovim = final: _prev: {
            neovim = self.wrappers.neovim.wrap {pkgs = final;};
          };
        };
        templates = {
          package = {
            path = ./templates/package;
            description = "Consume as a customized neovim package (devShell + package output)";
          };
          home-manager = {
            path = ./templates/home-manager;
            description = "Install and customize via home-manager";
          };
          nixos = {
            path = ./templates/nixos;
            description = "Install and customize system-wide via NixOS";
          };
          default = self.templates.package;
        };
      };

      perSystem = {
        pkgs,
        config,
        self',
        ...
      }: {
        packages.default = self'.packages.neovim;
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true; # nix
            stylua.enable = true; # lua
            taplo.enable = true; # toml
            prettier.enable = true; # markdown
          };
        };
        devShells.default = pkgs.mkShell {
          name = "nvim";
          packages = [
            self'.packages.neovim
            config.treefmt.build.wrapper # `treefmt` on PATH in the devShell
          ];
        };
      };
    };
}
