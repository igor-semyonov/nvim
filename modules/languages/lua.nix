{
  pkgs,
  mkCat,
  config,
  ...
}: {
  options.languages.lua.enable = mkCat "Lua tooling (lua-language-server, stylua)";
  config.specs.lua = {
    enable = config.languages.lua.enable;
    data = null;
    runtimePackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };
}
