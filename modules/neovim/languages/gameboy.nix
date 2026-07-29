{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.neovim-modules;

  vim-rgbds = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-rgbds";
    version = "unstable-2023-01-01";
    src = pkgs.fetchFromGitHub {
      owner = "EmmaEwert";
      repo = "vim-rgbds";
      rev = "8cb3a89a3404a9ddf51b10cf9f9b18df102f4488";
      hash = "sha256-X6RfZ5XEnIUNCPCNVAjxw5infooa5ZT5iUgLfiFEXbQ=";
    };
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.languages.gameboy.enable) {
    programs.neovim.plugins = [ vim-rgbds ];

    home.packages = [ pkgs.rgbds ];
  };
}
