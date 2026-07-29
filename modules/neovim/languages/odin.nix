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
  config = lib.mkIf (cfg.enable && cfg.languages.odin.enable) {
    programs.neovim-modules.treesitterParsers = [ "odin" ];

    xdg.configFile."nvim/lua/core/odin.lua".source = ./odin.lua;

    home.packages = [ pkgs.ols ];
  };
}