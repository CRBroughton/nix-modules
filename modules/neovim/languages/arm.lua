local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = ok and cmp_nvim_lsp.default_capabilities() or nil

vim.lsp.config('asm_lsp', {
    cmd = { 'asm-lsp' },
    capabilities = capabilities,
    filetypes = { 'asm', 's', 'S', 'vmasm' },
})
vim.lsp.enable('asm_lsp')
