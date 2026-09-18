local M = {}
local tiny = require('tiny-term')
local windows = require('tiny-term.window')
local terminals = require('tiny-term.terminal')
tiny.setup({ shell = vim.fn.executable('fish') == 1 and vim.fn.exepath('fish') or vim.o.shell })
require('config.terminal_tabs').setup()
require('config.terminal_view').setup()

-- Keep hidden panels across config reloads. Shells live in tiny-term buffers.
tiny.config_panels = tiny.config_panels or {}
local panels = tiny.config_panels
local function panel(position, anchor)
  local key = tostring(vim.api.nvim_get_current_tabpage()) .. ':' .. position
  if anchor then key = key .. ':' .. anchor end
  panels[key] = panels[key] or { position = position, anchor = anchor }
  return panels[key]
end

local function prepare_side(state)
  if state.position ~= 'right' then return end
  if not state.win or not vim.api.nvim_win_is_valid(state.win) then
    local anchor = state.anchor
    if not anchor or not vim.api.nvim_win_is_valid(anchor) then anchor = vim.api.nvim_get_current_win() end
    -- tiny-term normally uses botright. Supply a local split for it to stack in.
    vim.api.nvim_win_call(anchor, function()
      vim.cmd('rightbelow vsplit')
      state.win = vim.api.nvim_get_current_win()
    end)
  end
  windows.register_split('right', state.win)
end

local function current()
  for _, term in ipairs(tiny.list()) do
    if term.buf == vim.api.nvim_get_current_buf() then return term end
  end
end

local function capture_layout(position)
  local tree = require('nvim-tree.api').tree.winid()
  return {
    win = windows.get_split(position), tree = tree,
    tree_width = tree and vim.api.nvim_win_is_valid(tree) and vim.api.nvim_win_get_width(tree) or nil,
  }
end

local function tidy(win, position, previous, height)
  vim.wo[win].number, vim.wo[win].relativenumber, vim.wo[win].signcolumn = false, false, 'no'
  -- Adding a tab reuses a window: leave all split geometry untouched.
  if position ~= 'bottom' or win == previous.win then return end
  local tree = previous.tree
  if tree and vim.api.nvim_win_is_valid(tree) then
    -- A newly created bottom split spans the editor. Restore the full-height
    -- sidebar without accepting the half-screen width chosen by wincmd H.
    local layout = vim.fn.winlayout()
    if not (layout[1] == 'row' and layout[2][1][1] == 'leaf' and layout[2][1][2] == tree) then
      vim.api.nvim_win_call(tree, function() vim.cmd('wincmd H') end)
    end
    vim.api.nvim_win_set_width(tree, previous.tree_width)
  end
  vim.api.nvim_win_set_height(win, height or 14)
end

local function hide(term)
  local win = term.win
  if not win or not vim.api.nvim_win_is_valid(win) then return end
  local state = term.config_panel or panel(term.opts.win.position)
  state.height = vim.api.nvim_win_get_height(win)
  state.ids = vim.deepcopy(windows.get_split_terminals(win))
  state.active = vim.w[win].tiny_term_id
  for _, id in ipairs(state.ids) do
    local member = terminals.get(id)
    if member then member.win = nil end
  end
  vim.cmd.stopinsert()
  vim.api.nvim_win_close(win, true)
end

local function restore(state)
  if not state.ids then return end
  local previous = capture_layout(state.position)
  prepare_side(state)
  for _, id in ipairs(state.ids) do
    local term = terminals.get(id)
    if term and not term.exited then term:show() end
  end
  local win = windows.get_split(state.position)
  local active = terminals.get(state.active)
  if win and active and not active.exited then windows.switch_to_terminal(win, active.id) end
  state.ids, state.active = nil, nil
  if win then tidy(win, state.position, previous, state.height) end
end

local function adapt(term)
  -- Upstream closes the shared window, or drops a tab without stopping its job.
  -- Detach the closing tab first, then close its process and select a survivor.
  local close = term.close
  term.close = function(self)
    local win = self.win
    local active = win and vim.api.nvim_win_is_valid(win) and vim.w[win].tiny_term_id
    if win then windows.unregister_terminal_from_split(win, self.id) end
    self.win = nil
    if win and vim.api.nvim_win_is_valid(win) then
      local ids = windows.get_split_terminals(win)
      if #ids == 0 then
        vim.api.nvim_win_close(win, true)
      else
        windows.switch_to_terminal(win, active ~= self.id and active or ids[1])
      end
    end
    close(self)
  end
  term.hide = hide
  term.handle_exit = function(self) vim.schedule(function() self:close() end) end
end

function M.new(position, focus)
  position = position or 'bottom'
  local editor = vim.api.nvim_get_current_win()
  local focused = current()
  local state = position == 'right' and focused and focused.opts.win.position == 'right' and focused.config_panel
    or panel(position, position == 'right' and editor or nil)
  restore(state)
  local previous = capture_layout(position)
  prepare_side(state)
  local term = tiny.open(nil, {
    start_insert = false, auto_insert = false,
    win = { position = position, split_size = position == 'bottom' and (state.height or 14) or 60, stack = true,
      keys = { { 'q', function() M.toggle() end, desc = 'Hide terminal panel' } } },
  })
  term.config_panel = state
  adapt(term)
  tidy(term.win, position, previous, state.height)
  if focus == false then
    vim.cmd.stopinsert()
    vim.api.nvim_set_current_win(editor)
  else
    vim.api.nvim_set_current_win(term.win)
    vim.cmd.startinsert()
  end
  return term
end

function M.toggle()
  local term = current()
  local position = term and term.opts.win.position or 'bottom'
  local win = term and term.win or windows.get_split(position)
  if win then
    hide(assert(terminals.get(vim.w[win].tiny_term_id)))
  else
    restore(panel(position))
    win = windows.get_split(position)
    if not win then M.new(position); return end
    vim.api.nvim_set_current_win(win)
    vim.cmd.startinsert()
  end
end

function M.cycle(direction)
  local term = current()
  local win = term and term.win or windows.get_split('bottom')
  if not win then return end
  local ids = windows.get_split_terminals(win)
  for i, id in ipairs(ids) do
    if id == vim.w[win].tiny_term_id then
      windows.switch_to_terminal(win, ids[(i - 1 + direction) % #ids + 1])
      return
    end
  end
end

local function clicked(index, button)
  local mouse = button and vim.fn.getmousepos().winid or 0
  local win = mouse ~= 0 and mouse or vim.api.nvim_get_current_win()
  local ids = vim.w[win]._tiny_term_tab_ids or {}
  return terminals.get(ids[index]), win
end
_G.TinyTermTabClick = function(index, _, button)
  local term, win = clicked(index, button)
  if term then windows.switch_to_terminal(win, term.id) end
end
_G.TinyTermTabCloseClick = function(index, _, button)
  local term = clicked(index, button)
  if term then term:close() end
end

return M
