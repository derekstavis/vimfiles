-- A transient top winbar can disturb a TUI even when the final size is unchanged.
local terminal = require('config.terminal')
local windows = require('tiny-term.window')
local editor = vim.api.nvim_get_current_win()
local first = assert(require('tiny-term').list()[1])
local second = terminal.new()
vim.cmd.stopinsert()
local win, height = second.win, vim.api.nvim_win_get_height(second.win)
local changes = {}
local observer = vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'winbar',
  callback = function()
    if vim.wo[win].winbar ~= '' then
      changes[#changes + 1] = { height = vim.api.nvim_win_get_height(win), winbar = vim.wo[win].winbar }
    end
  end,
})
for _ = 1, 3 do
  windows.switch_to_terminal(win, first.id)
  windows.switch_to_terminal(win, second.id)
end
-- Reload must keep the same behavior and click-to-tab registry.
require('config.terminal_tabs').setup()
local third = terminal.new()
windows.switch_to_terminal(win, first.id)
assert(vim.w[win].tiny_term_id == first.id, 'Switching must retain the active terminal ID')
assert(vim.deep_equal(vim.w[win]._tiny_term_tab_ids, windows.get_split_terminals(win)),
  'Bottom tab click targets must remain synchronized')
third:close()
second:close()
vim.api.nvim_del_autocmd(observer)
vim.api.nvim_set_current_win(editor)
assert(#changes == 0, 'Tab operations must never create a top winbar: ' .. vim.inspect(changes))
assert(vim.api.nvim_win_get_height(win) == height, 'Tab operations must retain the terminal height')
print('PASS: terminal switches never create a transient top winbar')
