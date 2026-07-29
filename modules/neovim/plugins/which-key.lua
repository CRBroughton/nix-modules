return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
        require('which-key').setup({
            delay = 400,
        })
    end,
}
