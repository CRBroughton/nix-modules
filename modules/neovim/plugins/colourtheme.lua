return {
  '2nthony/vitesse.nvim',
  dependencies = {
    'tjdevries/colorbuddy.nvim',
  },
  lazy = false,
  priority = 1000,
  config = function()
    require('vitesse').setup({
      comment_italics = true,
      transparent_background = true,
      transparent_float_background = true,
      diagnostic_virtual_text_background = false,
    })

    vim.opt.winblend = 0
    vim.opt.pumblend = 0

    vim.cmd.colorscheme('vitesse')

    vim.api.nvim_set_hl(0, 'htmlTag', { fg = '#4d9375' })
    vim.api.nvim_set_hl(0, 'htmlTagN', { fg = '#4d9375' })

    vim.api.nvim_set_hl(0, '@lsp.type.component.vue', { fg = '#b8a965', bold = true })
  end,
}
