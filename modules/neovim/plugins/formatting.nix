{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.neovim-modules;

  formatters = lib.concatStringsSep "\n        "
    (lib.optionals cfg.languages.typescript.enable [
      "javascript = { 'eslint_d' },"
      "typescript = { 'eslint_d' },"
      "javascriptreact = { 'eslint_d' },"
      "typescriptreact = { 'eslint_d' },"
      "json = { 'eslint_d' },"
    ]
    ++ lib.optionals cfg.languages.vue.enable [
      "vue = { 'eslint_d' },"
    ]
    ++ lib.optionals cfg.languages.go.enable [
      "go = { 'goimports' },"
    ]
    ++ lib.optionals cfg.languages.nix.enable [
      "nix = { 'nixfmt' },"
    ]);

  formattingLua = ''
    return {
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        config = function()
            require('conform').setup({
                formatters_by_ft = {
                    ${formatters}
                },
                format_on_save = {
                    timeout_ms = 3000,
                    lsp_fallback = true,
                },
            })
        end,
    }
  '';
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."nvim/lua/plugins/formatting.lua".text = formattingLua;
  };
}
