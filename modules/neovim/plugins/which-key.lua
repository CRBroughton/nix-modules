return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local wk = require('which-key')
        wk.setup({ delay = 100 })

        vim.keymap.set('n', '<leader>?', '<Cmd>WhichKey<CR>', { desc = 'Show all keymaps' })
    end,
}
