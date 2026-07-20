# The neovim configuration, expressed as a nix-wrapper-modules module.
#
# This module can be:
#   - built into a package        (`nix build .#neovim`)
#   - imported into other flakes   (set any option below from there)
#   - installed via the generated home-manager / nixos modules
#
# Category toggles (`categories.<lang>.enable`) gate only the runtime
# dependencies (LSPs, formatters, CLI tools) for that language. All plugins
# stay always-on in the `core` spec, because init.lua requires them
# unconditionally. Everything defaults to enabled.
inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption mkDefault types;
  cats = config.categories;
  onLinux = pkgs.system == "x86_64-linux";
  # helper: an on-by-default umbrella/leaf toggle
  mkCat = desc: mkEnableOption desc // { default = true; };
in
{
  imports = [ wlib.wrapperModules.neovim ];

  # ---------------------------------------------------------------------------
  # Where the config lives. Picks up init.lua, lua/, plugin/, after/, spell/.
  # Provisioned by nix (was `wrapRc = true` under nixCats). For a live-editable
  # impure config instead, use:
  #   lib.generators.mkLuaInline "vim.fn.stdpath('config')"
  # ---------------------------------------------------------------------------
  config.settings.config_directory = ./.;
  config.settings.aliases = [ "vim" ];
  # To build against neovim-nightly instead of nixpkgs' neovim-unwrapped:
  # config.package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;

  # ---------------------------------------------------------------------------
  # Category toggles. Per-language leaves + a couple of umbrella categories
  # that cascade to their leaves via mkDefault (so the group toggles together,
  # but any individual leaf can still be overridden downstream).
  # ---------------------------------------------------------------------------
  options.categories = {
    lua.enable = mkCat "Lua tooling (lua-language-server, stylua)";
    nix.enable = mkCat "Nix tooling (nil, nixd, alejandra)";
    shell.enable = mkCat "Shell/Bash tooling (bash-language-server, shfmt, awk-ls)";
    yaml.enable = mkCat "YAML tooling (yaml-language-server, yamlfmt)";
    docker.enable = mkCat "Docker tooling (docker-compose-language-service)";
    rust.enable = mkCat "Rust tooling (rust-analyzer, clippy, rustfmt, taplo)";
    python.enable = mkCat "Python tooling (pyright, ruff, pyrefly, black, isort, pylsp)";
    latex.enable = mkCat "LaTeX tooling (texlab, ltex, texliveFull, vale)";
    cmake.enable = mkCat "CMake tooling (cmake, cmake-language-server, gersemi)";
    clang.enable = mkCat "C/C++ tooling (clang-tools)";
    matlab.enable = mkCat "MATLAB tooling (matlab-language-server)";
    hypr.enable = mkCat "Hyprland tooling (hyprls)";
    extras.enable = mkCat "Extra tools (ast-grep, lazygit)";
    images.enable = mkCat "Image/diagram rendering tools (linux only)";

    # Umbrella: web development. Enables the leaves below by default.
    web.enable = mkCat "Web development (umbrella over html/css/json/tailwind)";
    html.enable = mkEnableOption "HTML language server (vscode-langservers-extracted)";
    css.enable = mkEnableOption "CSS language server (vscode-langservers-extracted)";
    json.enable = mkEnableOption "JSON language server (vscode-langservers-extracted)";
    tailwind.enable = mkEnableOption "Tailwind CSS language server";
  };

  # Umbrella cascade: `web.enable` sets the default for each leaf. Because these
  # are mkDefault, a downstream user can still do e.g.
  #   categories.tailwind.enable = false;   # keep web on, drop tailwind
  # or turn a single leaf on while the umbrella is off.
  config.categories.html.enable = mkDefault cats.web.enable;
  config.categories.css.enable = mkDefault cats.web.enable;
  config.categories.json.enable = mkDefault cats.web.enable;
  config.categories.tailwind.enable = mkDefault cats.web.enable;

  # ---------------------------------------------------------------------------
  # Build plugins from `plugins-<name>` flake inputs (none today, but this
  # keeps the door open: add `inputs.plugins-foo = { url = ...; flake = false; }`
  # in flake.nix and reference `config.nvim-lib.neovimPlugins.foo` below).
  # ---------------------------------------------------------------------------
  options.nvim-lib.neovimPlugins = mkOption {
    readOnly = true;
    type = types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };
  options.nvim-lib.pluginsFromPrefix = mkOption {
    type = types.raw;
    readOnly = true;
    default =
      prefix: ins:
      lib.pipe ins [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
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
  config.specMods =
    { lib, ... }:
    {
      options.runtimePackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
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
      let
        nvim-lsp-endhints = pkgs.callPackage (import ./nix-additional-plugins/nvim-lsp-endhints.nix) { };
      in
      (with pkgs.vimPlugins; [
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
      ])
      ++ [ nvim-lsp-endhints ];
    # tools every session wants, regardless of language categories
    runtimePackages =
      (with pkgs; [
        ripgrep
        fzf
        taplo # toml
        xmlformat # xml
        yamlfmt
      ])
      ++ lib.optionals onLinux (with pkgs; [ wl-clipboard ]);
  };

  # ---------------------------------------------------------------------------
  # Per-language runtime dependency specs, each gated by its category toggle.
  # ---------------------------------------------------------------------------
  config.specs.lua = {
    enable = cats.lua.enable;
    data = null;
    runtimePackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.nix = {
    enable = cats.nix.enable;
    data = null;
    runtimePackages = with pkgs; [
      nil
      nixd
      alejandra
    ];
  };

  config.specs.shell = {
    enable = cats.shell.enable;
    data = null;
    runtimePackages = with pkgs; [
      bash-language-server
      awk-language-server
      shfmt
    ];
  };

  config.specs.yaml = {
    enable = cats.yaml.enable;
    data = null;
    runtimePackages = with pkgs; [ yaml-language-server ];
  };

  config.specs.docker = {
    enable = cats.docker.enable;
    data = null;
    runtimePackages = with pkgs; [ docker-compose-language-service ];
  };

  config.specs.rust = {
    enable = cats.rust.enable;
    data = null;
    runtimePackages = with pkgs; [
      rust-analyzer
      clippy
      rustfmt
    ];
  };

  config.specs.python = {
    enable = cats.python.enable;
    data = null;
    runtimePackages = with pkgs; [
      pyright
      python313Packages.python-lsp-server
      ruff
      pyrefly
      isort
      black
    ];
  };

  config.specs.latex = {
    enable = cats.latex.enable;
    data = null;
    runtimePackages =
      (with pkgs; [
        texlab
        ltex-ls
        ltex-ls-plus
        texliveFull
        vale
      ])
      ++ lib.optionals onLinux (with pkgs; [
        python313Packages.pylatexenc
        pnglatex
      ]);
  };

  config.specs.cmake = {
    enable = cats.cmake.enable;
    data = null;
    runtimePackages = with pkgs; [
      cmake
      cmake-language-server
      gersemi
    ];
  };

  config.specs.clang = {
    enable = cats.clang.enable;
    data = null;
    runtimePackages = with pkgs; [ clang-tools ];
  };

  config.specs.matlab = {
    enable = cats.matlab.enable;
    data = null;
    runtimePackages = with pkgs; [ matlab-language-server ];
  };

  config.specs.hypr = {
    enable = cats.hypr.enable;
    data = null;
    runtimePackages = with pkgs; [ hyprls ];
  };

  config.specs.extras = {
    enable = cats.extras.enable;
    data = null;
    runtimePackages =
      (with pkgs; [ ast-grep ])
      ++ lib.optionals onLinux (with pkgs; [ lazygit ]);
  };

  # web: leaves share vscode-langservers-extracted (html/css/json/eslint).
  config.specs.web = {
    # enabled if the umbrella or any leaf is on
    enable = cats.web.enable || cats.html.enable || cats.css.enable || cats.json.enable || cats.tailwind.enable;
    data = null;
    runtimePackages =
      lib.optionals (cats.html.enable || cats.css.enable || cats.json.enable) (
        with pkgs; [ vscode-langservers-extracted ]
      )
      ++ lib.optionals (cats.html.enable || cats.css.enable || cats.tailwind.enable) (with pkgs; [ prettier ])
      ++ lib.optionals cats.tailwind.enable (with pkgs; [ tailwindcss-language-server ]);
  };

  config.specs.images = {
    enable = cats.images.enable && onLinux;
    data = null;
    runtimePackages = lib.optionals onLinux (with pkgs; [
      imagemagickBig
      luajitPackages.magick
      ghostscript
      mermaid-cli
      ueberzugpp
      cairosvg
    ]);
  };

  # ---------------------------------------------------------------------------
  # Collect every enabled spec's runtimePackages onto neovim's PATH.
  # ---------------------------------------------------------------------------
  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePackages or [ ])) [ ];

  # Expose which categories are enabled to lua (optional; unused today).
  # Read in lua via `require(vim.g.nix_info_plugin_name)(nil, "info", "cats", "<name>")`.
  config.info.cats = builtins.mapAttrs (_: v: v.enable) cats;
}
