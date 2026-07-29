local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = ok and cmp_nvim_lsp.default_capabilities() or nil

vim.lsp.config('ts_ls', {
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    init_options = {
        plugins = {
            {
                name = '@vue/typescript-plugin',
                location = '__VUE_TS_PLUGIN_PATH__',
                languages = { 'vue' },
            },
        },
    },
})

vim.lsp.config('vue_ls', {
    capabilities = capabilities,
})
vim.lsp.enable('vue_ls')
