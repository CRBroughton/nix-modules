return {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local builtin = require('telescope.builtin')

        telescope.setup({
            defaults = {
                mappings = {
                    i = {
                        ['<C-j>'] = actions.move_selection_next,
                        ['<C-k>'] = actions.move_selection_previous,
                    },
                },
            },
        })

        pcall(telescope.load_extension, 'fzf')

        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find file' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep,  { desc = 'Live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers,    { desc = 'Find buffer' })
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles,   { desc = 'Recent files' })

        local ok, wk = pcall(require, 'which-key')
        if ok then
            wk.add({
                { '<leader>f',  group = 'Find' },
                { '<leader>ff', desc = 'Find file' },
                { '<leader>fg', desc = 'Live grep' },
                { '<leader>fb', desc = 'Find buffer' },
                { '<leader>fr', desc = 'Recent files' },
            })
        end
    end,
}
