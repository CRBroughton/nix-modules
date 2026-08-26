return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { '__PARSERS__' },
    highlight = { enable = true },
  },
}
