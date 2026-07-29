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
    ./languages/gameboy.nix
    ./languages/nix.nix
    ./languages/go.nix
    ./languages/odin.nix
    ./languages/typescript.nix
    ./languages/vue.nix
    ./languages/tailwind.nix
    ./plugins/bufferline.nix
    ./plugins/flash.nix
    ./plugins/formatting.nix
    ./plugins/harpoon.nix
    ./plugins/lsp.nix
    ./plugins/telescope.nix
    ./plugins/theme.nix
    ./plugins/which-key.nix
  ];

  options.programs.neovim-modules = {
    enable = lib.mkEnableOption "Neovim editor";

    languages = {
      typescript.enable = lib.mkEnableOption "Typescript (ts_ls + eslint via nix)";
      vue.enable = lib.mkEnableOption "Vue (vue_ls via nix, requires the typescript plugin to be enabled)";
      tailwind.enable = lib.mkEnableOption "Tailwind (via nix)";
      nix.enable = lib.mkEnableOption "Nix (nil_ls via nix)";
      gameboy.enable = lib.mkEnableOption "Game Boy assembly (RGBDS via nix)";
      go.enable = lib.mkEnableOption "Go (gopls via go)";
      odin.enable = lib.mkEnableOption "Odin (ols via nix)";
    };

    plugins = {
      bufferline.enable = lib.mkEnableOption "Bufferline (buffer tab bar)";
      flash.enable      = lib.mkEnableOption "Flash (jump to label)";
      harpoon.enable    = lib.mkEnableOption "Harpoon 2 (file bookmarks)";
      telescope.enable  = lib.mkEnableOption "Telescope (fuzzy finder)";
      theme.enable      = lib.mkEnableOption "Theme (vitesse)";
      which-key.enable  = lib.mkEnableOption "Which-key (keymap popup)";
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
      pkgs.tree-sitter
    ];

    xdg.configFile = lib.mkMerge [
      {
        "nvim/init.lua".source = ./core/init.lua;
        "nvim/lua/core/options.lua".source = ./core/options.lua;
        "nvim/lua/core/keymaps.lua".source = ./core/keymaps.lua;
        "nvim/lua/plugins/completion.lua".source = ./core/completion.lua;
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
