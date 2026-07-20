{
  pkgs,
  mkCat,
  config,
  ...
}: {
  options.languages.shell.enable = mkCat "Shell/Bash tooling (bash-language-server, shfmt, awk-ls)";
  config.specs.shell = {
    enable = config.languages.shell.enable;
    data = null;
    runtimePackages = with pkgs; [
      bash-language-server
      awk-language-server
      shfmt
    ];
  };
}
