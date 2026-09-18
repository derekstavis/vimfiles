-- Runs from tests/ui.lua with an editor and bottom terminal already open.
local api = require('nvim-tree.api')
local preview = require('nvim-tree-preview')
local temp = vim.fn.tempname()
vim.fn.mkdir(temp .. '/folder', 'p')
vim.fn.writefile({ 'first preview' }, temp .. '/one.txt')
vim.fn.writefile({ 'second preview' }, temp .. '/two.txt')
vim.fn.writefile({ 'nested file' }, temp .. '/folder/nested.txt')
local function key(lhs) vim.fn.maparg(lhs, 'n', false, true).callback() end
local function select(name)
  local win = api.tree.winid()
  vim.api.nvim_set_current_win(win)
  for row = 1, vim.api.nvim_buf_line_count(0) do
    vim.api.nvim_win_set_cursor(win, { row, 0 })
    local node = api.tree.get_node_under_cursor()
    if node and node.name == name then
      vim.api.nvim_exec_autocmds('CursorMoved', { buffer = vim.api.nvim_get_current_buf() })
      return node
    end
  end
  error('Tree entry missing: ' .. name)
end
local function preview_text()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf):match('^nvim%-tree%-preview://') then
      return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    end
  end
end
local function check_docked()
  local win = assert(api.tree.winid())
  assert(vim.api.nvim_win_get_config(win).relative == '', 'Tree must be a docked split')
  local layout = vim.fn.winlayout()
  assert(layout[1] == 'row' and layout[2][1][2] == win, 'Tree must occupy the full left side beside editor and terminal')
  assert(vim.api.nvim_win_get_width(win) == 32, 'Tree must retain sidebar width')
end
local function check_preview_area(left, right)
  right = right or left
  local instance = require('nvim-tree-preview.manager').instance
  local win = assert(instance.preview_win)
  local config = vim.api.nvim_win_get_config(win)
  local left_info, right_info = vim.fn.getwininfo(left)[1], vim.fn.getwininfo(right)[1]
  local preview_info = vim.fn.getwininfo(win)[1]
  assert(config.border == nil or config.border == 'none', 'Preview must not have a border')
  assert(preview_info.wincol == left_info.wincol and preview_info.winrow == left_info.winrow,
    'Preview must align with the adjacent editor row: ' .. vim.inspect({ preview = preview_info, editor = left_info, config = config }))
  assert(config.width == right_info.wincol + right_info.width - left_info.wincol, 'Preview must span the combined editor widths')
  assert(preview_info.height + preview_info.winbar == math.min(left_info.height + left_info.winbar + left_info.status_height,
    right_info.height + right_info.winbar + right_info.status_height), 'Preview must stop at the bottom of the editor row')
  local title = vim.api.nvim_eval_statusline(vim.wo[win].winbar, { winid = win, use_winbar = true }).str
  assert(title:find('one.txt', 1, true), 'Borderless preview must retain its filename header')
  local color = vim.api.nvim_get_hl(0, { name = 'ExplorerPreviewNormal', link = false })
  assert(color.bg == tonumber(require('gruvbox').palette.dark0:sub(2), 16), 'Preview must use the lighter Gruvbox background')
end

local editor
for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
  if vim.api.nvim_win_get_config(win).relative == '' and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == '' then
    editor = win
    break
  end
end
assert(editor, 'Expected an editor beside the terminal')
api.tree.open({ path = temp })
check_docked()
select('one.txt')
assert(vim.wait(3000, function() return preview_text() == 'first preview' end, 20), 'Automatic file preview did not open')
check_preview_area(editor)
key('?')
local function check_help_above_preview()
  local help_win = vim.api.nvim_get_current_win()
  local help_config = vim.api.nvim_win_get_config(help_win)
  local preview_win = assert(require('nvim-tree-preview.manager').instance.preview_win)
  assert(help_config.relative ~= '' and help_win ~= preview_win, 'Help must open a focused overlay')
  assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]:find('nvim-tree mappings', 1, true), 'Expected tree help')
  assert(help_config.zindex > vim.api.nvim_win_get_config(preview_win).zindex, 'Help must appear above the preview')
end
check_help_above_preview()
key('s')
check_help_above_preview()
key('?')
assert(vim.api.nvim_get_current_win() == api.tree.winid() and preview.is_open(),
  'Closing help must return to the tree with its preview intact')
-- Use the real rename mappings and input loop, including full-path variants.
local function rename_prompt(lhs, input)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local pos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
  local checked, failure
  vim.defer_fn(function()
    checked, failure = pcall(function()
      local state = assert(MiniInput.get_state(), 'Rename input must be active')
      assert(state.opts.scope == 'cursor', 'Tree rename must use cursor scope')
      local info = vim.fn.getwininfo(state.data.floatwin_win_id)[1]
      assert(info.winrow > pos.row and info.winrow - pos.row <= 3 and math.abs(info.wincol - pos.col) <= 3,
        'Rename popup must appear just below the selected entry')
    end)
    vim.api.nvim_feedkeys(vim.keycode(input), 'nt', false)
  end, 100)
  key(lhs)
  assert(checked, failure or 'Rename popup was not inspected')
  assert(vim.api.nvim_get_current_win() == api.tree.winid(), 'Rename must preserve tree focus')
end
for _, lhs in ipairs({ 'r', 'u', '<C-r>' }) do
  rename_prompt(lhs, '<Esc>')
  assert(vim.uv.fs_stat(temp .. '/one.txt'), 'Cancelling rename must preserve the file')
end
-- Long temporary paths in success notifications otherwise trigger hit-enter.
local notify = require('nvim-tree.config').g.notify
local threshold = notify.threshold
notify.threshold = vim.log.levels.WARN
rename_prompt('r', '<C-u>renamed.txt<CR>')
assert(vim.uv.fs_stat(temp .. '/renamed.txt') and not vim.uv.fs_stat(temp .. '/one.txt'),
  'Confirming rename must rename the selected file')
select('renamed.txt')
rename_prompt('r', '<C-u>one.txt<CR>')
notify.threshold = threshold
select('one.txt')
-- Exercise actual resize events while the preview is open, including a width
-- too narrow for its original dimensions. Let the UI event loop run each time.
local original_columns, original_lines = vim.o.columns, vim.o.lines
local function settle_resize()
  local thread = coroutine.running()
  vim.defer_fn(function() assert(coroutine.resume(thread)) end, 100)
  coroutine.yield()
  assert(vim.v.errmsg == '', 'Resize reported an error: ' .. vim.v.errmsg)
  local instance = require('nvim-tree-preview.manager').instance
  assert(instance:is_valid(), 'Resize must keep the preview open')
  local config = vim.api.nvim_win_get_config(instance.preview_win)
  assert(config.width <= math.max(1, vim.o.columns - vim.api.nvim_win_get_width(api.tree.winid()) - 1), 'Preview must fit beside the tree')
  assert(vim.api.nvim_get_current_win() == api.tree.winid(), 'Resize must preserve focus')
end
vim.v.errmsg = ''
for _, term in ipairs(require('tiny-term').list()) do
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_set_height(term.win, 8)
    break
  end
end
settle_resize()
for _, size in ipairs({ { 60, 24 }, { 120, 40 }, { original_columns, original_lines } }) do
  vim.o.columns, vim.o.lines = size[1], size[2]
  settle_resize()
  check_preview_area(editor)
end
-- Reproduce the requested layout: two editors above a third editor, with a
-- terminal panel underneath. Only the top two editors should be covered.
vim.api.nvim_set_current_win(editor)
vim.cmd('belowright split')
local lower_editor = vim.api.nvim_get_current_win()
vim.api.nvim_set_current_win(editor)
vim.cmd('rightbelow vsplit')
local right_editor = vim.api.nvim_get_current_win()
select('one.txt')
assert(vim.wait(3000, preview.is_open, 20), 'Preview must reopen in the multi-split layout')
settle_resize()
check_preview_area(editor, right_editor)
vim.api.nvim_win_close(right_editor, true)
vim.api.nvim_set_current_win(editor)
local side = require('config.terminal').new('right')
select('one.txt')
assert(vim.wait(3000, preview.is_open, 20), 'Preview must open beside a side terminal')
settle_resize()
check_preview_area(editor)
side:close()
vim.api.nvim_win_close(lower_editor, true)
select('one.txt')
assert(vim.wait(3000, preview.is_open, 20), 'Preview must reopen after closing extra splits')
settle_resize()
select('two.txt')
assert(vim.wait(3000, function() return preview_text() == 'second preview' end, 20), 'Preview must follow the selection')
select('folder')
assert(vim.wait(1000, function() return not preview.is_open() end), 'Selecting a directory must close the file preview')
assert(preview.is_watching(), 'Selecting a directory must preserve automatic file previews')
key('<Tab>')
assert(not preview.is_open(), 'Tab must not open a directory preview')
select('one.txt')
assert(vim.wait(3000, function() return preview_text() == 'first preview' end, 20), 'File previews must resume after selecting a directory')
key('P')
assert(not preview.is_open() and not preview.is_watching(), 'P must disable previews')
select('folder')
local windows = #vim.api.nvim_list_wins()
key('l')
assert(#vim.api.nvim_list_wins() == windows, 'Expanding directories must not open panels')
select('nested.txt')
key('h')
assert(api.tree.get_node_under_cursor().name == 'folder', 'h must close the parent directory')
select('one.txt')
key('<CR>')
assert(vim.api.nvim_buf_get_name(0):match('/one%.txt$'), 'Enter must open the selected file')
check_docked()
assert(vim.bo.filetype ~= 'NvimTree', 'Opening a file must focus the editor')
key(',1')
assert(not api.tree.is_visible(), ',1 must close the docked tree from the editor')
key(',1')
check_docked()
select('one.txt')
key('P')
assert(vim.wait(3000, preview.is_open, 20), 'P must re-enable previews')
key('<Tab>')
assert(vim.wait(1000, preview.is_focused, 20), 'Tab must focus the preview')
key('<Esc>')
vim.wait(100)
assert(not preview.is_open() and api.tree.is_visible(), 'Escape must dismiss the preview without closing the sidebar or reopening the preview')
api.tree.close()
vim.g.explorer_previews = true
vim.fn.delete(temp, 'rf')
print('PASS: full-height tree, preview following/toggle/focus, in-place expansion, persistent sidebar')
