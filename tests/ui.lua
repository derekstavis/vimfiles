-- Run in a terminal: nvim -c 'autocmd VimEnter * ++once luafile tests/ui.lua'
local function run()
  assert(package.loaded['config.autocmds'], 'Configuration failed during UI startup')
  local terms = vim.tbl_filter(function(b) return vim.bo[b].buftype == 'terminal' end, vim.api.nvim_list_bufs())
  assert(#terms == 1, 'Expected one startup terminal')
  assert(vim.bo.buftype ~= 'terminal', 'Editor must retain focus')
  local win = vim.fn.bufwinid(terms[1])
  assert(vim.api.nvim_win_get_height(win) == 14, 'Startup terminal must be 14 lines tall')
  assert(vim.wo[win].signcolumn == 'no', 'Terminal must hide sign column')
  local count = #vim.api.nvim_get_autocmds({group='ConfigAutocmds'})
  vim.fn.maparg(',sv', 'n', false, true).callback()
  assert(#vim.api.nvim_get_autocmds({group='ConfigAutocmds'}) == count, 'Reload duplicated autocommands')
  vim.fn.maparg('<C-p>', 'n', false, true).callback()
  assert(vim.bo.filetype == 'TelescopePrompt', 'Ctrl-P must open Telescope')
  require('telescope.actions').close(vim.api.nvim_get_current_buf())
  vim.fn.maparg(',fs', 'n', false, true).callback()
  assert(vim.api.nvim_win_get_config(0).relative ~= '', 'Focus must zoom the buffer')
  vim.fn.maparg(',fs', 'n', false, true).callback()
  assert(vim.api.nvim_win_get_config(0).relative == '', 'Focus must restore the split')
  assert(loadfile(vim.fn.stdpath('config') .. '/tests/terminal.lua'))()
  assert(loadfile(vim.fn.stdpath('config') .. '/tests/terminal_resize.lua'))()
  assert(loadfile(vim.fn.stdpath('config') .. '/tests/explorer.lua'))()
  print('PASS: interactive startup, terminal layout/focus, reload, Telescope, zoom')
end
-- Leave VimEnter so explorer window/buffer events can run normally.
vim.schedule(coroutine.wrap(function()
  local ok, err = xpcall(run, debug.traceback)
  if vim.env.NVIM_TEST_RESULT then
    vim.fn.writefile(vim.split(ok and 'PASS' or err, '\n'), vim.env.NVIM_TEST_RESULT)
  end
  if not ok then
    io.stderr:write(err .. '\n')
    vim.cmd.cquit({ args = { '1' } })
  else
    vim.cmd('qa!')
  end
end))
