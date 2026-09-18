-- Run inside the interactive UI test coroutine so real resize events fire.
local editor = vim.api.nvim_get_current_win()
local term = require('config.terminal').new()
local win, buf, job = term.win, term.buf, term.job_id
vim.api.nvim_win_set_height(win, 8)
local output = 'i=1; while [ "$i" -le 300 ]; do printf "history %03d\\n" "$i"; i=$((i+1)); done'
vim.api.nvim_chan_send(job, 'sh -c ' .. vim.fn.shellescape(output) .. '\r')
assert(job > 0, 'Could not start the scrollback fixture')
assert(vim.wait(3000, function() return vim.api.nvim_buf_line_count(buf) >= 300 end), 'Terminal history did not arrive')
vim.cmd.stopinsert()
local function settle()
  local thread = coroutine.running()
  vim.defer_fn(function() assert(coroutine.resume(thread)) end, 100)
  coroutine.yield()
end
local function info() return vim.fn.getwininfo(win)[1] end
local function scroll(top)
  vim.api.nvim_win_call(win, function()
    vim.fn.winrestview({ topline = top, lnum = top + 1, col = 0 })
  end)
  settle()
end
local function resize(height)
  vim.api.nvim_win_set_height(win, height)
  settle()
end
settle()
scroll(1)
resize(14)
assert(info().topline == 1, 'Growing at the top must reveal history below')
resize(8)
assert(info().topline == 1, 'Shrinking at the top must retain the first line')
scroll(100)
local center = info().topline + (info().height - 1) / 2
resize(14)
assert(math.abs(info().topline + (info().height - 1) / 2 - center) <= 0.5,
  'Growing in scrollback must preserve the visible center: ' .. vim.inspect(info()))
resize(8)
assert(math.abs(info().topline + (info().height - 1) / 2 - center) <= 0.5, 'Shrinking in scrollback must preserve the visible center')
for _ = 1, 3 do resize(9); resize(8) end
assert(info().topline + (info().height - 1) / 2 == center, 'Repeated one-line resizes must not drift through history')
-- Reaching an edge during a resize must not turn a centered view into a pinned one.
for _, top in ipairs({ 6, vim.api.nvim_buf_line_count(buf) - 10 }) do
  scroll(top)
  center = info().topline + (info().height - 1) / 2
  resize(18)
  resize(8)
  assert(info().topline + (info().height - 1) / 2 == center,
    'Resizing through a scrollback edge must retain the original center: ' .. vim.inspect(info()))
end
vim.api.nvim_win_call(win, function() vim.cmd('normal! Gzb') end)
settle()
resize(14)
assert(info().botline >= vim.api.nvim_buf_line_count(buf), 'Growing at the bottom must retain the newest output')
resize(8)
assert(info().botline >= vim.api.nvim_buf_line_count(buf), 'Shrinking at the bottom must retain the newest output')
vim.cmd.startinsert()
settle()
assert(vim.api.nvim_get_mode().mode == 't', 'Expected terminal input mode')
resize(14)
assert(vim.api.nvim_get_mode().mode == 't' and info().botline >= vim.api.nvim_buf_line_count(buf),
  'Resizing in terminal input mode must keep input active and show the newest output')
vim.cmd.stopinsert()
resize(8)
-- Resizing an unfocused terminal must preserve its history and editor focus.
scroll(100)
center = info().topline + (info().height - 1) / 2
vim.api.nvim_set_current_win(editor)
resize(14)
assert(vim.api.nvim_get_current_win() == editor, 'Resize must not steal editor focus')
assert(math.abs(info().topline + (info().height - 1) / 2 - center) <= 0.5, 'Unfocused terminal must retain its scrollback center')
local columns, lines = vim.o.columns, vim.o.lines
for _, size in ipairs({ { 100, 40 }, { 60, 24 }, { columns, lines } }) do
  center = info().topline + (info().height - 1) / 2
  vim.o.columns, vim.o.lines = size[1], size[2]
  settle()
  assert(math.abs(info().topline + (info().height - 1) / 2 - center) <= 0.5,
    'Whole-window resize must preserve the scrollback center: ' .. vim.inspect(info()))
end
term:close()
print('PASS: terminal scrollback anchors at top, bottom, and center during resize')
