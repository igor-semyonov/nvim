{ pkgs, mkCat, config, ... }:
{
  options.languages.tailwind.enable = mkCat "Tailwind CSS tooling (tailwindcss-language-server, prettier)";
  config.specs.tailwind = {
    enable = config.languages.tailwind.enable;
    data = null;
    runtimePackages = with pkgs; [
      tailwindcss-language-server
      prettier
    ];
  };
}
