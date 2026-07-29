{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.plugins.which-key.enable) {
    xdg.configFile."nvim/lua/plugins/which-key.lua".source = ./which-key.lua;
  };
}
