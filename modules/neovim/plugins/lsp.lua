return {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
                local opts = { buffer = args.buf }

                vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,    vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
                vim.keymap.set('n', 'K',          vim.lsp.buf.hover,         vim.tbl_extend('force', opts, { desc = 'Hover docs' }))
                vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename,        vim.tbl_extend('force', opts, { desc = 'Rename' }))
                vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action,   vim.tbl_extend('force', opts, { desc = 'Code action' }))
                vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'Diagnostics' }))
                vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,  vim.tbl_extend('force', opts, { desc = 'Prev diagnostic' }))
                vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,  vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
            end,
        })

        local ok, wk = pcall(require, 'which-key')
        if ok then
            wk.add({
                { '<leader>l',  group = 'LSP' },
                { '<leader>lr', desc = 'Rename' },
                { '<leader>la', desc = 'Code action' },
                { '<leader>ld', desc = 'Diagnostics' },
                { 'gd',  desc = 'Go to definition' },
                { 'grr', desc = 'References' },
                { 'grn', desc = 'Rename' },
                { 'gra', desc = 'Code action' },
                { 'K',   desc = 'Hover docs' },
                { '[d',         desc = 'Prev diagnostic' },
                { ']d',         desc = 'Next diagnostic' },
            })
        end
    end,
}
