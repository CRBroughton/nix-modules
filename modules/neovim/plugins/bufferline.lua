return {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('bufferline').setup({
            options = {
                mode = 'buffers',
                show_buffer_close_icons = false,
                show_close_icon = false,
                separator_style = 'thin',
            },
        })

        vim.keymap.set('n', '<S-h>', '<Cmd>BufferLineCyclePrev<CR>', { silent = true, desc = 'Previous buffer' })
        vim.keymap.set('n', '<S-l>', '<Cmd>BufferLineCycleNext<CR>', { silent = true, desc = 'Next buffer' })

        local ok, wk = pcall(require, 'which-key')
        if ok then
            wk.add({
                { '<leader>b', group = 'Buffers' },
                { '<S-h>',     desc = 'Previous buffer' },
                { '<S-l>',     desc = 'Next buffer' },
            })
        end
    end,
}
