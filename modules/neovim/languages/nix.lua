local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = ok and cmp_nvim_lsp.default_capabilities() or nil

vim.lsp.config('nil_ls', {
    capabilities = capabilities,
    settings = {
        ['nil'] = {
            formatting = {
                command = { 'nixfmt' },
            },
        },
    },
})
vim.lsp.enable('nil_ls')
