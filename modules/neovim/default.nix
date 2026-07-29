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
  imports = [
    ./languages/nix.nix
    ./languages/go.nix
    ./languages/odin.nix
    ./languages/typescript.nix
    ./languages/vue.nix
    ./languages/tailwind.nix
    ./plugins/telescope.nix
    ./plugins/theme.nix
  ];

  options.programs.neovim-modules = {
    enable = lib.mkEnableOption "Neovim editor";

    languages = {
      typescript.enable = lib.mkEnableOption "Typescript (ts_ls + eslint via nix)";
      vue.enable = lib.mkEnableOption "Vue (vue_ls via nix, requires the typescript plugin to be enabled)";
      tailwind.enable = lib.mkEnableOption "Tailwind (via nix)";
      nix.enable = lib.mkEnableOption "Nix (nil_ls via nix)";
      go.enable = lib.mkEnableOption "Go (gopls via go)";
      odin.enable = lib.mkEnableOption "Odin (ols via nix)";
    };

    plugins = {
      telescope.enable = lib.mkEnableOption "Telescope (fuzzy finder)";
      theme.enable = lib.mkEnableOption "Theme (vitesse)";
    };

    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages you require to be installed";
    };

    treesitterParsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra treesitter parsers requested by enabled language modules";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
    };

    home.packages = [
      pkgs.lua5_1
      pkgs.lua5_1.pkgs.luarocks
    ];

    xdg.configFile = lib.mkMerge [
      {
        "nvim/init.lua".source = ./core/init.lua;
        "nvim/lua/plugins/completion.lua".source = ./core/completion.lua;
        "nvim/lua/plugins/lspconfig.lua".source = ./core/lspconfig.lua;
        "nvim/lua/plugins/treesitter.lua".text = builtins.replaceStrings [ "'__PARSERS__'" ] [
          (lib.concatMapStringsSep ", " (p: "'${p}'") ([ "lua" "vim" "vimdoc" ] ++ cfg.treesitterParsers))
        ] (builtins.readFile ./core/treesitter.lua);
      }
      (lib.listToAttrs (map(plugin: {
        name = "nvim/lua/plugins/${plugin.name}.lua";
        value = { source = plugin.src; };
      }) cfg.extraPlugins))
    ];
  };
}
