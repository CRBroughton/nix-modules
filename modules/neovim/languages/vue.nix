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
  config = lib.mkIf (cfg.enable && cfg.languages.vue.enable) {
    assertions = [
      {
        assertion = cfg.languages.typescript.enable;
        message = "programs.neovim-modules.languages.vue requires programs.neovim-modules.languages.typescript to be enabled";
      }
    ];

    programs.neovim-modules.treesitterParsers = [ "vue" ];

    xdg.configFile."nvim/lua/core/vue.lua".text = builtins.replaceStrings
      [ "'__VUE_TS_PLUGIN_PATH__'" ]
      [ "'${pkgs.vue-language-server}/lib/language-tools/packages/language-server'" ]
      (builtins.readFile ./vue.lua);

    home.packages = [ pkgs.vue-language-server ];
  };
}
