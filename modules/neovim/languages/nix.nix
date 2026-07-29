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
  config = lib.mkIf (cfg.enable && cfg.languages.nix.enable) {
    programs.neovim-modules.treesitterParsers = [ "nix" ];

    xdg.configFile."nvim/lua/core/nix.lua".source = ./nix.lua;

    home.packages = with pkgs; [
      nil
      nixfmt
    ];
  };
}