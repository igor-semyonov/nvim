{
  pkgs,
  mkCat,
  config,
  ...
}: {
  options.languages.docker.enable = mkCat "Docker tooling (docker-compose-language-service)";
  config.specs.docker = {
    enable = config.languages.docker.enable;
    data = null;
    runtimePackages = with pkgs; [docker-compose-language-service];
  };
}
