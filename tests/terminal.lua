local terminal = require('config.terminal')
local tiny = require('tiny-term')
local windows = require('tiny-term.window')
local editor = vim.api.nvim_get_current_win()
local first = assert(tiny.list()[1])
local first_job, first_buf = first.job_id, first.buf
local win = first.win
local count = #vim.api.nvim_list_wins()
local second = terminal.new()
vim.cmd.stopinsert()
assert(second.win == win and #vim.api.nvim_list_wins() == count, 'New terminals must share one panel')
local function check_bar(win)
  assert(vim.wo[win].winbar == '', 'Terminal tabs must not occupy a top winbar')
  assert(vim.wo[win].statusline:find('config.terminal_tabs', 1, true), 'Terminal tabs must replace the regular statusline')
  require('lualine').refresh({ scope = 'all', force = true })
  assert(vim.wo[win].statusline:find('config.terminal_tabs', 1, true), 'Lualine refresh must preserve terminal tabs')
  return vim.api.nvim_eval_statusline(vim.wo[win].statusline, { winid = win }).str
end
local tabs = check_bar(win)
local shell_icon = MiniIcons.get('filetype', 'sh')
assert(tabs:find('1 ' .. shell_icon, 1, true) and tabs:find('2 ' .. shell_icon, 1, true), 'Both tabs must show Nerd Font shell icons')
assert(tabs:find('', 1, true), 'Terminal tabs must use lualine-style separators')
local replacement = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(replacement, vim.fn.tempname() .. '.txt')
for _ = 1, 2 do
  vim.api.nvim_win_set_buf(win, replacement)
  require('lualine').refresh({ scope = 'all', force = true })
  assert(not vim.wo[win].statusline:find('config.terminal_tabs', 1, true), 'Editor buffers must show the regular statusline')
  vim.api.nvim_win_set_buf(win, second.buf)
  check_bar(win)
  vim.api.nvim_set_current_win(editor)
  check_bar(win)
  vim.api.nvim_set_current_win(win)
  require('config.terminal_tabs').setup()
  check_bar(win)
end
vim.api.nvim_buf_delete(replacement, { force = true })
-- Run the remote editor from the shell so deleting its buffer must unblock nvr.
assert(vim.fn.executable('nvr') == 1, 'The terminal editor test requires nvr')
local edit_dir = vim.fn.tempname()
vim.fn.mkdir(edit_dir, 'p')
local commit_file, resumed = edit_dir .. '/COMMIT_EDITMSG', edit_dir .. '/resumed'
vim.fn.writefile({ '# Write a commit message' }, commit_file)
local edit_command = table.concat({
  vim.fn.shellescape(vim.fn.exepath('nvr')), '--servername', vim.fn.shellescape(vim.v.servername),
  '--remote-wait', vim.fn.shellescape(commit_file),
  '&& printf resumed >', vim.fn.shellescape(resumed),
}, ' ')
local panel_height = vim.api.nvim_win_get_height(win)
local function wait_for_remote(predicate)
  for _ = 1, 250 do
    if predicate() then return true end
    local thread = coroutine.running()
    vim.defer_fn(function() assert(coroutine.resume(thread)) end, 20)
    coroutine.yield()
  end
  return predicate()
end
vim.api.nvim_chan_send(second.job_id, 'sh -c ' .. vim.fn.shellescape(edit_command) .. '\r')
assert(wait_for_remote(function()
  return vim.uv.fs_realpath(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))) == vim.uv.fs_realpath(commit_file)
end), 'nvr must open the commit message in the calling terminal split: ' .. vim.inspect({
  expected = commit_file, actual = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)),
}))
local commit_buf = vim.api.nvim_win_get_buf(win)
assert(vim.bo[commit_buf].filetype == 'gitcommit', 'Expected a Git editor buffer')
assert(vim.fn.filereadable(resumed) == 0, 'nvr must wait until its buffer is deleted')
require('lualine').refresh({ scope = 'all', force = true })
vim.api.nvim_buf_set_lines(commit_buf, 0, -1, false, { 'Test terminal editor round trip' })
vim.cmd('silent write')
vim.cmd.BD()
assert(vim.api.nvim_win_get_buf(win) == second.buf, ':BD must return to the terminal that called nvr')
assert(wait_for_remote(function() return vim.fn.filereadable(resumed) == 1 end), ':BD must release nvr and resume the shell')
assert(vim.fn.readfile(commit_file)[1] == 'Test terminal editor round trip', 'The commit message must be saved')
assert(#vim.api.nvim_list_wins() == count and vim.api.nvim_win_get_height(win) == panel_height,
  'The remote editor must preserve the terminal split layout')
assert(vim.w[win].tiny_term_id == second.id and #windows.get_split_terminals(win) == 2,
  'Returning from nvr must preserve the active terminal and its tabs')
check_bar(win)
vim.fn.delete(edit_dir, 'rf')
local labels = require('config.terminal_tabs')
local fixture = vim.api.nvim_create_buf(false, true)
vim.b[fixture].osc7_dir, vim.b[fixture].term_title = '/work/project', 'Live title'
assert(labels.label(fixture, { cmd = { '/usr/bin/python', '-i' } }) == 'Live title', 'Live title must take priority over cwd and program')
vim.b[fixture].term_title = nil
assert(labels.label(fixture, { cmd = { '/usr/bin/python', '-i' } }) == 'project', 'Reported cwd must take priority over the fallback program')
vim.b[fixture].osc7_dir = nil
assert(labels.label(fixture, { cmd = { '/usr/bin/python', '-i' } }) == 'python', 'Program name must be used when title and cwd are absent')
assert(labels.label(fixture) == 'shell', 'Missing terminal metadata must fall back to shell')
vim.api.nvim_buf_delete(fixture, { force = true })
local directory = vim.fn.tempname() .. '/shell% tabs'
vim.fn.mkdir(directory, 'p')
local editor_cwd = vim.fn.getcwd()
if vim.fn.executable('fish') == 1 then
  vim.api.nvim_chan_send(second.job_id, 'cd ' .. vim.fn.shellescape(directory) .. '\r')
  assert(vim.wait(3000, function() return vim.b[second.buf].osc7_dir == directory end), 'Shell cd must update the reported directory')
  assert(vim.wait(3000, function() return (vim.b[second.buf].term_title or ''):find('shell%% tabs') end), 'Shell cd must update the live title')
  local displayed_title = vim.fn.strcharpart(vim.b[second.buf].term_title, 0, 24)
  assert(check_bar(win):find(displayed_title, 1, true), 'The tab must display the updated shell title')
  assert(vim.fn.getcwd() == editor_cwd, 'Shell directory changes must not change the editor cwd')
end
assert(vim.fn.maparg('[t', 'n') == '' and vim.fn.maparg(']t', 'n') == '', 'Old terminal cycling shortcuts must be removed')
vim.fn.maparg('<C-[>', 'n', false, true).callback()
assert(vim.api.nvim_get_current_buf() == first_buf, 'Previous terminal must select its buffer')
vim.fn.maparg('<C-]>', 'n', false, true).callback()
assert(vim.api.nvim_get_current_buf() == second.buf, 'Next terminal must select its buffer')
check_bar(win)
terminal.toggle()
assert(not windows.get_split('bottom'), 'Toggle must hide the panel')
local jobs = vim.fn.jobwait({ first_job, second.job_id }, 0)
assert(jobs[1] == -1 and jobs[2] == -1, 'Hiding must preserve running shells')
terminal.toggle()
win = second.win
assert(#windows.get_split_terminals(win) == 2, 'Reopening must restore all terminal tabs')
assert(vim.api.nvim_get_current_buf() == second.buf, 'Reopening must retain the active tab')
check_bar(win)
local second_job, second_buf = second.job_id, second.buf
vim.api.nvim_set_current_win(editor)
vim.cmd.stopinsert()
vim.cmd('redraw!')
local clicked = false
for row = 1, vim.o.lines do
  local cells = {}
  for col = 1, vim.o.columns do cells[col] = vim.fn.screenstring(row, col) end
  local line = table.concat(cells)
  local tab = line:find('2 ' .. shell_icon, 1, true)
  local cross = tab and line:find('✕', tab, true)
  if cross then
    local top = vim.api.nvim_win_get_position(win)[1]
    assert(row == top + vim.api.nvim_win_get_height(win) + 1, 'Clickable tabs must be below the terminal content')
    vim.api.nvim_input_mouse('left', 'press', '', 0, row - 1, vim.fn.strdisplaywidth(line:sub(1, cross - 1)))
    clicked = true
    break
  end
end
assert(clicked, 'The terminal tab close button must be rendered')
local thread = coroutine.running()
vim.defer_fn(function() assert(coroutine.resume(thread)) end, 50)
coroutine.yield()
assert(vim.wait(2000, function() return vim.fn.jobwait({ second_job }, 0)[1] ~= -1 end), 'Closing a tab must stop its shell')
assert(not vim.api.nvim_buf_is_valid(second_buf), 'Closing a tab must remove its terminal buffer')
vim.fn.delete(vim.fn.fnamemodify(directory, ':h'), 'rf')
assert(vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == first_buf, 'Closing a tab must keep the other shell visible')
local exiting = terminal.new()
vim.api.nvim_chan_send(exiting.job_id, 'exit\r')
assert(vim.wait(3000, function() return not exiting:buf_valid() end), 'Shell exit must close its tab')
assert(vim.api.nvim_win_is_valid(first.win), 'Shell exit must preserve the remaining panel')

local tree = require('nvim-tree.api').tree
tree.open()
vim.api.nvim_win_set_width(tree.winid(), 27)
vim.api.nvim_win_set_height(first.win, 8)
vim.api.nvim_set_current_win(editor)
local before_height, before_width = vim.api.nvim_win_get_height(first.win), vim.api.nvim_win_get_width(tree.winid())
vim.fn.maparg(',sh', 'n', false, true).callback()
vim.cmd.stopinsert()
local added = require('tiny-term.terminal').get(vim.w[first.win].tiny_term_id)
assert(vim.api.nvim_win_get_height(first.win) == before_height and vim.api.nvim_win_get_width(tree.winid()) == before_width,
  ('Adding a terminal tab must preserve panel height and tree width: expected %d/%d, got %d/%d'):format(
    before_height, before_width, vim.api.nvim_win_get_height(first.win), vim.api.nvim_win_get_width(tree.winid())))
added:close()
vim.api.nvim_set_current_win(editor)
terminal.toggle()
terminal.toggle()
local layout = vim.fn.winlayout()
assert(layout[1] == 'row' and layout[2][1][2] == tree.winid(), 'Reopening terminals must keep the tree full-height')
assert(vim.api.nvim_win_get_height(first.win) == before_height, 'Restoring terminals must retain the resized panel height')
assert(vim.api.nvim_win_get_width(tree.winid()) == before_width, 'Restoring terminals must retain the resized tree width')
tree.close()
vim.api.nvim_set_current_win(editor)
local bottom_height = vim.api.nvim_win_get_height(first.win)
local side = terminal.new('right')
check_bar(side.win)
assert(side.win ~= first.win and windows.get_split('right') == side.win, 'Vertical terminals must use a separate right panel')
local layout = vim.fn.winlayout()
assert(layout[1] == 'col' and layout[2][1][1] == 'row'
  and layout[2][1][2][1][2] == editor and layout[2][1][2][2][2] == side.win
  and layout[2][2][2] == first.win, 'Vertical terminal must sit beside the editor above the bottom terminal')
assert(vim.api.nvim_win_get_height(first.win) == bottom_height, 'Opening a side terminal must preserve the bottom panel height')
-- A different editor split gets its own adjacent terminal, rather than reusing
-- a panel elsewhere in the layout.
vim.api.nvim_set_current_win(editor)
vim.cmd('belowright split')
local another_editor = vim.api.nvim_get_current_win()
local another_side = terminal.new('right')
local pair = vim.fn.winlayout()[2][1][2][1][2][2]
assert(pair[1] == 'row' and pair[2][1][2] == another_editor and pair[2][2][2] == another_side.win,
  'Each editor split must get an adjacent terminal')
vim.api.nvim_set_current_win(side.win)
terminal.toggle()
assert(another_side:is_visible(), 'Hiding one side panel must leave the other visible')
vim.api.nvim_set_current_win(editor)
local restored_side = terminal.new('right')
assert(side.win == restored_side.win and side:buf_valid(), 'Hidden tabs must restore beside their original editor')
restored_side:close()
another_side:close()
vim.api.nvim_win_close(another_editor, true)
side:close()
assert(not windows.get_split('right') and first:buf_valid(), 'Closing the last side tab must preserve the bottom shell')
vim.cmd.stopinsert()
vim.api.nvim_set_current_win(editor)
print('PASS: terminal tabs, cycling, hide/restore, close/exit cleanup, tree layout')
