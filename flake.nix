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
    # importApply threads `inputs` into module.nix and keeps it a first-class
    # module (so downstream flakes can import it and override options).
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        wrappers.flakeModules.wrappers
        treefmt-nix.flakeModule
      ];
      systems = nixpkgs.lib.platforms.all;

      # Registers the module and auto-generates `packages.<system>.neovim`.
      flake.wrappers.neovim = module;

      # Generically-importable home-manager / nixos modules.
      # Enable with `wrappers.neovim.enable = true;` and set any option.
      flake.nixosModules.neovim = wrappers.lib.getInstallModule {
        name = "neovim";
        value = module;
      };
      flake.nixosModules.default = self.nixosModules.neovim;
      flake.homeModules.neovim = self.nixosModules.neovim;
      flake.homeModules.default = self.nixosModules.neovim;

      # Overlay replacing pkgs.neovim with the wrapped config.
      flake.overlays.neovim = final: _prev: {
        neovim = self.wrappers.neovim.wrap {pkgs = final;};
      };
      flake.overlays.default = self.overlays.neovim;

      # Starter flakes for consuming this config. Init with:
      #   nix flake init -t github:igor-semyonov/nvim#<name>
      flake.templates = {
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

      perSystem = {
        pkgs,
        config,
        ...
      }: {
        # `wrappers.flakeModules.wrappers` generates `packages.<sys>.neovim`;
        # alias it to `default` so `nix run .` / `nix build .` work.
        packages.default = self.packages.${pkgs.system}.neovim;

        # `nix fmt` formats the repo; `nix flake check` verifies formatting.
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
            self.packages.${pkgs.system}.neovim
            config.treefmt.build.wrapper # `treefmt` on PATH in the devShell
          ];
        };
      };
    };
}
