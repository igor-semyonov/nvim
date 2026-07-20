{
  lib,
  mkCat,
  config,
  ...
}: {
  options.groups.web.enable = mkCat "Web development (html, css, json, tailwind)";

  # Cascade the group's value to each member language at mkDefault priority, so
  # the whole set toggles together but any member can still be overridden:
  #   groups.web.enable = false;      # drop the web set
  #   languages.json.enable = true;   # ...but keep JSON
  config.languages.html.enable = lib.mkDefault config.groups.web.enable;
  config.languages.css.enable = lib.mkDefault config.groups.web.enable;
  config.languages.json.enable = lib.mkDefault config.groups.web.enable;
  config.languages.tailwind.enable = lib.mkDefault config.groups.web.enable;
}
