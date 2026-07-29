{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf (cfg.enable && cfg.plugins.conventional-commit.enable) {
    xdg.configFile."nvim/lua/core/conventional_commit.lua".source = ../core/conventional_commit.lua;
  };
}
