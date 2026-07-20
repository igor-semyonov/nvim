inputs: {
  config,
  options,
  wlib,
  lib,
  pkgs,
  system,
  ...
}: {
  imports = [
    wlib.wrapperModules.neovim
    (inputs.import-tree ./modules)
  ];

  # Expose helpers/args to the imported modules via _module.args.
  config._module.args = {
    inherit inputs;
    onLinux = system == "x86_64-linux";
    # an on-by-default toggle, overridable by disableAll (see below)
    mkCat = desc: lib.mkEnableOption desc // {default = true;};
    system = pkgs.stdenv.hostPlatform.system;
  };

  # ---------------------------------------------------------------------------
  # Where the config lives. Picks up init.lua, lua/, plugin/, after/, spell/.
  # Provisioned by nix (was `wrapRc = true` under nixCats). For a live-editable
  # impure config instead, use:
  #   lib.generators.mkLuaInline "vim.fn.stdpath('config')"
  # ---------------------------------------------------------------------------
  config.settings.config_directory = ./.;
  config.settings.aliases = ["vim"];

  options.settings.nightly.enable = lib.mkEnableOption "Use neovim nightly";
  config.package = lib.mkIf config.settings.nightly.enable inputs.neovim-nightly-overlay.packages.${system}.neovim;

  # ---------------------------------------------------------------------------
  # `disableAll`: a master off-switch. It forces every toggle to false at an
  # ultra-low priority (1250) that sits *below* each option's `default = true`
  # (1500) but *above* group cascades (mkDefault, 1000) and explicit user sets
  # (100). So it disables everything by default, yet `groups.web.enable = true`
  # or `languages.rust.enable = true` still turns those specific ones back on.
  # ---------------------------------------------------------------------------
  options.disableAll = lib.mkEnableOption "disabling every language/group/tool by default";
  # Read names from `options.*` (static, declaration-derived) rather than
  # `config.*` to avoid a self-referential definition / infinite recursion.
  config.languages = lib.mkIf config.disableAll (
    lib.genAttrs (builtins.attrNames options.languages) (_: {enable = lib.mkOverride 1250 false;})
  );
  config.groups = lib.mkIf config.disableAll (
    lib.genAttrs (builtins.attrNames options.groups) (_: {enable = lib.mkOverride 1250 false;})
  );
  config.tools = lib.mkIf config.disableAll (
    lib.genAttrs (builtins.attrNames options.tools) (_: {enable = lib.mkOverride 1250 false;})
  );

  # ---------------------------------------------------------------------------
  # Build plugins from `plugins-<name>` flake inputs (none today, but this
  # keeps the door open: add `inputs.plugins-foo = { url = ...; flake = false; }`
  # in flake.nix and reference `config.nvim-lib.neovimPlugins.foo` below).
  # ---------------------------------------------------------------------------
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default = prefix: ins:
      lib.pipe ins [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input: let
            name = lib.removePrefix prefix input;
          in {
            inherit name;
            value = config.nvim-lib.mkPlugin name ins.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };

  # ---------------------------------------------------------------------------
  # Add a per-spec `runtimePackages` field. Packages listed here are added to
  # neovim's PATH only when the spec is enabled. Collected at the bottom.
  # ---------------------------------------------------------------------------
  config.specMods = {lib, ...}: {
    options.runtimePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Packages placed on neovim's PATH when this spec is enabled.";
    };
  };

  # ---------------------------------------------------------------------------
  # Plugins. All loaded at startup (lazy = false), matching the previous
  # nixCats `startupPlugins`. init.lua drives all plugin setup itself, so no
  # per-spec config/lze is needed.
  # ---------------------------------------------------------------------------
  config.specs.core = {
    data =
      (with config.nvim-lib.neovimPlugins; [
        # plugins from flake.inputs.plugins-*
        nvim-lsp-endhints
      ])
      ++ (with pkgs.vimPlugins; [
        nightfox-nvim
        nvim-colorizer-lua
        lualine-nvim
        nvim-web-devicons

        # cmp
        nvim-cmp
        lspkind-nvim
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-path
        cmp-buffer
        luasnip
        cmp_luasnip
        friendly-snippets
        cmp-nvim-lua

        # delimiters
        vim-surround
        auto-pairs
        rainbow-delimiters-nvim

        oil-nvim
        which-key-nvim
        nvim-ufo
        promise-async
        nerdcommenter
        gitsigns-nvim
        plenary-nvim
        diffview-nvim
        neogit
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-smart-history-nvim
        nvim-treesitter.withAllGrammars
        vim-illuminate
        lsp_signature-nvim
        conform-nvim
        lazydev-nvim
        neoconf-nvim
        nvim-lspconfig
        mason-nvim
        vim-tmux-navigator
        otter-nvim
        codesettings-nvim
        rustaceanvim
        nvim-lint

        # from the old `general` startup set
        vimtex
        fzf-lua
        img-clip-nvim
      ]);
    # tools every session wants, regardless of language toggles
    runtimePackages =
      (with pkgs; [
        ripgrep
        fzf
        taplo # toml
        xmlformat # xml
        yamlfmt
      ])
      ++ lib.optionals pkgs.stdenv.isLinux [pkgs.wl-clipboard];
  };

  # ---------------------------------------------------------------------------
  # Collect every enabled spec's runtimePackages onto neovim's PATH.
  # ---------------------------------------------------------------------------
  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePackages or [])) [];

  # Expose which languages are enabled to lua (optional; unused today).
  # Read in lua via `require(vim.g.nix_info_plugin_name)(nil, "info", "languages", "<name>")`.
  config.info.languages = builtins.mapAttrs (_: v: v.enable) config.languages;
}
