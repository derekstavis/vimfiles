local labels = require('config.terminal_tabs')
local previous = vim.api.nvim_get_current_buf()
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
local channel = vim.api.nvim_open_term(buf, {})
local function title(value)
  -- Use actual OSC output so Neovim supplies b:term_title itself.
  vim.api.nvim_chan_send(channel, '\027]2;' .. value .. '\007')
  assert(vim.wait(1000, function() return vim.b[buf].term_title == value end), 'OSC title was not received')
end
local ok, err = xpcall(function()
  vim.b[buf].osc7_dir = '/work/nvim'
  title('Agent task | nvim')
  assert(labels.label(buf, { cmd = { '/usr/bin/fish' } }) == 'Agent task | nvim',
    'Reported title must take priority over cwd and the launch command')
  title('Build 50%')
  assert(labels.label(buf) == 'Build 50%', 'Tab labels must follow subsequent title changes')
  local rendered = vim.api.nvim_eval_statusline("%!v:lua.require'config.terminal_tabs'.render()", {}).str
  assert(rendered:find('Build 50%', 1, true), 'Rendered title must preserve literal percent signs')
  vim.b[buf].neordr_label = 'Named terminal'
  assert(labels.label(buf) == 'Named terminal', 'An explicit terminal label must override the reported title')
  vim.b[buf].neordr_label = nil
  vim.b[buf].term_title = ''
  assert(labels.label(buf) == 'nvim', 'Empty titles must fall back to the reported cwd')
  vim.b[buf].osc7_dir = nil
  assert(labels.label(buf, { cmd = { '/usr/bin/python', '-i' } }) == 'python',
    'A known program must be used when title and cwd are absent')
end, debug.traceback)
vim.api.nvim_set_current_buf(previous)
vim.api.nvim_buf_delete(buf, { force = true })
assert(ok, err)
