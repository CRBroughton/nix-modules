{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.plugins.flash.enable) {
    xdg.configFile."nvim/lua/plugins/flash.lua".source = ./flash.lua;
  };
}
