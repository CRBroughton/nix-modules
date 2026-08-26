{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.plugins.theme.enable) {
    xdg.configFile."nvim/lua/plugins/colourtheme.lua".source = ./colourtheme.lua;
  };
}
