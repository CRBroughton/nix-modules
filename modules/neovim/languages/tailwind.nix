{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.languages.tailwind.enable) {
    xdg.configFile."nvim/lua/core/tailwind.lua".source = ./tailwind.lua;

    home.packages = [ pkgs.tailwindcss-language-server ];
  };
}
