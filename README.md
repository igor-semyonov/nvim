# nvim

My neovim config, built with [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) + [flake-parts](https://flake.parts).

The config lives in `init.lua` + `lua/`. `module.nix` wraps it into a portable neovim derivation. Language/tool toggles live in their own files under `modules/` (pulled in via [import-tree](https://github.com/vic/import-tree)) — **adding a language is just dropping a file in `modules/languages/`**.

Toggle namespaces (all default to enabled):

- `languages.<lang>.enable` — LSPs/formatters/linters for a language
- `groups.<name>.enable` — an agglomeration that cascades to a set of languages (e.g. `groups.web` → html/css/json/tailwind); a group cascades at `mkDefault`, so you can drop the group and keep one language
- `tools.<name>.enable` — non-language tool bundles (`images`, `extras`)
- `disableAll` — master off-switch; set it, then enable just what you want (`disableAll = true; groups.web.enable = true;` → only the web languages)

## Run / build locally

```bash
nix run .            # launch
nix build .          # -> ./result/bin/nvim (aliased as `vim`)
nix fmt              # format nix/lua/toml/markdown (treefmt; checked by `nix flake check`)
```

## Consume from another flake

Exports: `wrappers.neovim` (evaluated module), `packages.<sys>.neovim`, `overlays.default`, `homeModules.default` / `nixosModules.default`, and starter `templates`.

Init a ready-to-edit consumer flake for your use case:

```bash
nix flake init -t github:igor-semyonov/nvim#package        # wrapper: devShell + package
nix flake init -t github:igor-semyonov/nvim#home-manager   # home-manager
nix flake init -t github:igor-semyonov/nvim#nixos          # NixOS
```

Everything defaults to enabled — each template only sets what it changes. Common overrides:

```nix
wrappers.neovim.languages.latex.enable = false; # drop a language's tooling
wrappers.neovim.groups.web.enable = false;      # drop the web set (html/css/json/tailwind)
wrappers.neovim.languages.json.enable = true;   # ...but keep one language
wrappers.neovim.disableAll = true;              # or: start from nothing, enable what you want
```

For the config unchanged, use `mynvim.packages.${system}.neovim` directly.
