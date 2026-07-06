{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.zellij-modules;
in
{
  options.programs.zellij-modules = {
    enable = lib.mkEnableOption "Zellij terminal multiplexer";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
    };

    xdg.configFile."zellij/config.kdl".text = ''
      theme "vitesse-dark"
      default_shell "${pkgs.fish}/bin/fish"
      editor "${pkgs.helix}/bin/hx"
      default_layout "compact"
      pane_frames false
      auto_attach true
      auto_close false

      themes {
        vitesse-dark {
          fg "#dbd7ca"
          bg "#121212"
          black "#121212"
          red "#cb7676"
          green "#4d9375"
          yellow "#e6cc77"
          blue "#6394bf"
          magenta "#db889a"
          cyan "#5eaab5"
          white "#959da5"
          orange "#d4976c"
        }
      }
    '';
  };
}
