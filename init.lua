if vim.fn.has('nvim-0.12') == 0 then
  error('This configuration requires Neovim 0.12 or newer (vim.pack).')
end

vim.g.mapleader = ','
vim.g.maplocalleader = "'"

require('config.options')
require('config.plugins')
require('config.mini')
require('config.explorer')
require('config.languages')
require('config.integrations')
require('config.neordr')
require('config.terminal')
require('config.keymaps')
require('config.autocmds')
