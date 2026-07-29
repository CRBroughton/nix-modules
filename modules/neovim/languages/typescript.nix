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
  config = lib.mkIf (cfg.enable && cfg.languages.typescript.enable) {
    programs.neovim-modules.treesitterParsers = [ "typescript" "tsx" ];

    xdg.configFile."nvim/lua/core/typescript.lua".source = ./typescript.lua;

    home.packages = with pkgs; [
      typescript
      typescript-language-server
      vscode-langservers-extracted
    ];
  };
}
