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
  config = lib.mkIf (cfg.enable && cfg.languages.arm.enable) {
    programs.neovim-modules.treesitterParsers = [ "asm" ];

    xdg.configFile."nvim/lua/core/arm.lua".source = ./arm.lua;

    xdg.configFile."asm-lsp/.asm-lsp.toml".text = ''
      [default_config]
      assembler = "gas"
      instruction_set = "arm"

      [default_config.opts]
      diagnostics = false
      default_diagnostics = true
    '';

    home.packages = [ pkgs.asm-lsp ];
  };
}
