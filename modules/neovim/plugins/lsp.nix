{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."nvim/lua/plugins/lsp.lua".source = ./lsp.lua;
  };
}
