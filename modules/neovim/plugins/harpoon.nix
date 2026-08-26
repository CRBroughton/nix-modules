{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.plugins.harpoon.enable) {
    xdg.configFile."nvim/lua/plugins/harpoon.lua".source = ./harpoon.lua;
  };
}
