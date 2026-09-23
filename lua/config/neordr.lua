local root = vim.fn.expand('~/Workspace/neordr')
local bin = vim.fn.expand('~/.local/bin/neordr')
if vim.fn.isdirectory(root .. '/lua/neordr') == 0 or vim.fn.executable(bin) == 0 then return end

vim.opt.runtimepath:prepend(root)
require('neordr').setup({
  bin = bin,
  split_terminal = function(opts)
    opts.split = {target_win=opts.target_win, direction=opts.direction, ratio=opts.ratio}
    return require('config.terminal').new(opts.direction == 'right' and 'right' or 'bottom', true, opts).buf
  end,
  close_terminal = require('neordr.tiny_term').close,
  reorder_terminals = require('neordr.tiny_term').reorder,
  create_terminal = function(opts) return require('config.terminal').new('bottom', true, opts).buf end,
  focus_terminal = function(buf) return require('config.terminal').focus_buffer(buf) end,
  label_terminal = function(buf) return require('config.terminal_tabs').label(buf) end,
})
