{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.helix-modules;

  vueTypescriptPluginNm = pkgs.runCommand "vue-typescript-plugin-nm" { } ''
    mkdir -p $out/node_modules/@vue
    ln -s ${pkgs.vue-language-server}/lib/language-tools/packages/typescript-plugin \
          $out/node_modules/@vue/typescript-plugin
  '';

  unocss-language-server = pkgs.buildNpmPackage {
    pname = "unocss-language-server";
    version = "66.7.4";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@unocss/language-server/-/language-server-66.7.4.tgz";
      hash = "sha256-4XNZ+F8EGrDmP/mQpk3gbt3Qbbfd4h2n3FwxVGI5tFc=";
    };
    postPatch = ''
      cp ${./unocss-language-server-lock.json} package-lock.json
    '';
    npmDepsHash = "sha256-WkCKIVmQ+s0Ps47PHO2q4Z+r8j4Cb5wrvOm1r2WAp8Y=";
    dontNpmBuild = true;
  };

  mkEslintFmt = ext: pkgs.writeShellScriptBin "eslint-fmt-${ext}" ''
    exec ${pkgs.eslint_d}/bin/eslint_d \
      --fix-to-stdout \
      --stdin \
      --stdin-filename "stdin.${ext}"
  '';
  eslint-fmt-ts  = mkEslintFmt "ts";
  eslint-fmt-tsx = mkEslintFmt "tsx";
  eslint-fmt-vue = mkEslintFmt "vue";

  tsServers =
    lib.optionals cfg.languages.typescript.enable [ "typescript-language-server" "eslint" ]
    ++ lib.optionals cfg.languages.tailwind.enable [ "tailwindcss" ]
    ++ lib.optionals cfg.languages.unocss.enable   [ "unocss" ];

  vueServers =
    lib.optionals cfg.languages.vue.enable [
      "vls"
      { name = "typescript-language-server"; except-features = [ "format" ]; }
      "eslint"
    ]
    ++ lib.optionals cfg.languages.tailwind.enable [ "tailwindcss" ]
    ++ lib.optionals cfg.languages.unocss.enable   [ "unocss" ];

  htmlServers =
    [ "vscode-html-language-server" ]
    ++ lib.optionals cfg.languages.tailwind.enable [ "tailwindcss" ]
    ++ lib.optionals cfg.languages.unocss.enable   [ "unocss" ];

  cssServers =
    [ "vscode-css-language-server" ]
    ++ lib.optionals cfg.languages.tailwind.enable [ "tailwindcss" ]
    ++ lib.optionals cfg.languages.unocss.enable   [ "unocss" ];
in
{
  options.programs.helix-modules = {
    enable = lib.mkEnableOption "Helix editor";

    languages = {
      typescript.enable = lib.mkEnableOption "TypeScript/TSX" // { default = true; };
      vue.enable        = lib.mkEnableOption "Vue"            // { default = true; };
      go.enable         = lib.mkEnableOption "Go"             // { default = true; };
      odin.enable       = lib.mkEnableOption "Odin"           // { default = true; };
      nix.enable        = lib.mkEnableOption "Nix"            // { default = true; };
      tailwind.enable   = lib.mkEnableOption "Tailwind CSS"   // { default = true; };
      unocss.enable     = lib.mkEnableOption "UnoCSS"         // { default = true; };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;
      defaultEditor = false;

      settings = {
        theme = "vitesse_dark";
        editor = {
          line-number = "relative";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides.render = false;
          soft-wrap.enable = true;
          auto-format = true;
          completion-trigger-len = 1;
          lsp = {
            display-inlay-hints = true;
            display-color-swatches = false;
          };
          statusline = {
            left   = [ "mode" "spinner" "spacer" "file-name" "file-modification-indicator" ];
            center = [ "diagnostics" ];
            right  = [ "version-control" "spacer" "file-type" "file-encoding" "position" ];
            separator = "│";
            mode.normal = "NORMAL";
            mode.insert = "INSERT";
            mode.select = "SELECT";
          };
        };
        keys.normal = {
          space.space = "file_picker";
          space.l = "diagnostics_picker";
          space.r = "rename_symbol";
          space.a = "code_action";
        };
      };

      languages = {
        language-server = lib.mkMerge [
          (lib.mkIf (cfg.languages.typescript.enable || cfg.languages.vue.enable) {
            typescript-language-server = {
              command = lib.getExe pkgs.typescript-language-server;
              args = [ "--stdio" ];
              config.plugins = [{
                name = "@vue/typescript-plugin";
                location = "${vueTypescriptPluginNm}";
                languages = [ "vue" ];
              }];
            };
            eslint = {
              command = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
              args = [ "--stdio" ];
              config.experimental.useFlatConfig = true;
            };
          })
          (lib.mkIf cfg.languages.vue.enable {
            vls = {
              command = lib.getExe pkgs.vue-language-server;
              args = [ "--stdio" ];
              config = {
                typescript.tsdk = "node_modules/typescript/lib";
                hybridMode = false;
              };
            };
          })
          (lib.mkIf cfg.languages.go.enable {
            gopls.command = lib.getExe pkgs.gopls;
          })
          (lib.mkIf cfg.languages.odin.enable {
            ols.command = lib.getExe pkgs.ols;
          })
          (lib.mkIf cfg.languages.nix.enable {
            nixd.command = lib.getExe pkgs.nixd;
          })
          (lib.mkIf cfg.languages.tailwind.enable {
            tailwindcss = {
              command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
              args = [ "--stdio" ];
            };
          })
          (lib.mkIf cfg.languages.unocss.enable {
            unocss = {
              command = "${unocss-language-server}/bin/unocss-language-server";
              args = [ "--stdio" ];
            };
          })
        ];

        language =
          lib.optionals (cfg.languages.typescript.enable || cfg.languages.tailwind.enable || cfg.languages.unocss.enable) [
            { name = "html"; language-servers = htmlServers; }
            { name = "css";  language-servers = cssServers; }
          ]
          ++ lib.optionals cfg.languages.typescript.enable [
            { name = "typescript"; language-servers = tsServers; formatter.command = "${eslint-fmt-ts}/bin/eslint-fmt-ts"; auto-format = true; }
            { name = "tsx";        language-servers = tsServers; formatter.command = "${eslint-fmt-tsx}/bin/eslint-fmt-tsx"; auto-format = true; }
          ]
          ++ lib.optionals cfg.languages.vue.enable [
            { name = "vue"; language-servers = vueServers; formatter.command = "${eslint-fmt-vue}/bin/eslint-fmt-vue"; auto-format = true; }
          ]
          ++ lib.optionals cfg.languages.go.enable [
            { name = "go"; language-servers = [ "gopls" ]; formatter.command = "${pkgs.gofumpt}/bin/gofumpt"; auto-format = true; }
          ]
          ++ lib.optionals cfg.languages.odin.enable [
            { name = "odin"; language-servers = [ "ols" ]; auto-format = true; }
          ]
          ++ lib.optionals cfg.languages.nix.enable [
            { name = "nix"; language-servers = [ "nixd" ]; formatter.command = "${pkgs.nixfmt}/bin/nixfmt"; auto-format = true; }
          ];
      };
    };

    xdg.configFile."helix/themes/vitesse_dark.toml".source = ./vitesse_dark.toml;

    home.packages =
      lib.optionals (cfg.languages.typescript.enable || cfg.languages.vue.enable) (with pkgs; [
        eslint-fmt-ts eslint-fmt-tsx typescript-language-server typescript vscode-langservers-extracted eslint_d
      ])
      ++ lib.optionals cfg.languages.vue.enable       [ eslint-fmt-vue pkgs.vue-language-server ]
      ++ lib.optionals cfg.languages.go.enable        (with pkgs; [ gopls gofumpt ])
      ++ lib.optionals cfg.languages.odin.enable      [ pkgs.ols ]
      ++ lib.optionals cfg.languages.nix.enable       [ pkgs.nixd pkgs.nixfmt ]
      ++ lib.optionals cfg.languages.tailwind.enable  [ pkgs.tailwindcss-language-server ]
      ++ lib.optionals cfg.languages.unocss.enable    [ unocss-language-server ];
  };
}
