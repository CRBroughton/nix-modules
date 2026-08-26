{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.plugins.telescope.enable) {
    xdg.configFile."nvim/lua/plugins/telescope.lua".source = ./telescope.lua;
  };
}
