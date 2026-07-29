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
  config = lib.mkIf (cfg.enable && cfg.languages.go.enable) {
    programs.neovim-modules.treesitterParsers = [ "go" ];

    xdg.configFile."nvim/lua/core/go.lua".source = ./go.lua;

    home.packages = with pkgs; [
      gopls
      goimports-reviser
    ];
  };
}