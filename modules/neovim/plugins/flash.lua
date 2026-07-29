return {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
        { 's',     mode = { 'n', 'x', 'o' }, function() require('flash').jump() end,              desc = 'Flash jump' },
        { 'S',     mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end,        desc = 'Flash treesitter' },
        { 'r',     mode = 'o',               function() require('flash').remote() end,            desc = 'Flash remote' },
        { 'R',     mode = { 'o', 'x' },      function() require('flash').treesitter_search() end, desc = 'Flash treesitter search' },
        { '<C-s>', mode = { 'c' },           function() require('flash').toggle() end,            desc = 'Toggle flash search' },
    },
    config = function(_, opts)
        require('flash').setup(opts)

        local ok, wk = pcall(require, 'which-key')
        if ok then
            wk.add({
                { 's', desc = 'Flash jump',       mode = { 'n', 'x', 'o' } },
                { 'S', desc = 'Flash treesitter', mode = { 'n', 'x', 'o' } },
            })
        end
    end,
}
