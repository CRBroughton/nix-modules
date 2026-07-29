local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = ok and cmp_nvim_lsp.default_capabilities() or nil

vim.lsp.config('ts_ls', {
    capabilities = capabilities,
})
vim.lsp.enable('ts_ls')

vim.lsp.config('eslint', {
    capabilities = capabilities,
    settings = {
        workingDirectories = { mode = 'auto' },
    },
})
vim.lsp.enable('eslint')
