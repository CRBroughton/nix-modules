return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
        local wk = require('which-key')
        wk.setup({ delay = 400 })

        vim.keymap.set('n', '<leader>?', function() wk.show() end, { desc = 'Show keymaps' })
    end,
}
