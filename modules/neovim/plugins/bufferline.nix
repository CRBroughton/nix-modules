{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.plugins.bufferline.enable) {
    xdg.configFile."nvim/lua/plugins/bufferline.lua".source = ./bufferline.lua;
  };
}
