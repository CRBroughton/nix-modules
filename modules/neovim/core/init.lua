local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('error clone lazy.nvim:\n' .. out)
    end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

local config_dir = vim.fn.stdpath('config')

for _, file in ipairs(vim.fn.glob(config_dir .. '/lua/core/*.lua', false, true)) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    pcall(require, 'core.' .. name)
end

local specs = {}
for _, file in ipairs(vim.fn.glob(config_dir .. '/lua/plugins/*.lua', false, true)) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    local ok, spec = pcall(require, 'plugins.' .. name)
    if ok and spec then
        table.insert(specs, spec)
    end
end

require('lazy').setup(specs, {})