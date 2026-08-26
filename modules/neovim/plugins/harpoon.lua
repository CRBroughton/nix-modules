return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local harpoon = require('harpoon')
        harpoon:setup()

        vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end,                       { desc = 'Add file' })
        vim.keymap.set('n', '<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Menu' })
        vim.keymap.set('n', '<leader>h1', function() harpoon:list():select(1) end,                   { desc = 'File 1' })
        vim.keymap.set('n', '<leader>h2', function() harpoon:list():select(2) end,                   { desc = 'File 2' })
        vim.keymap.set('n', '<leader>h3', function() harpoon:list():select(3) end,                   { desc = 'File 3' })
        vim.keymap.set('n', '<leader>h4', function() harpoon:list():select(4) end,                   { desc = 'File 4' })

        local ok, wk = pcall(require, 'which-key')
        if ok then
            wk.add({
                { '<leader>h',  group = 'Harpoon' },
                { '<leader>ha', desc = 'Add file' },
                { '<leader>hh', desc = 'Menu' },
                { '<leader>h1', desc = 'File 1' },
                { '<leader>h2', desc = 'File 2' },
                { '<leader>h3', desc = 'File 3' },
                { '<leader>h4', desc = 'File 4' },
            })
        end
    end,
}
