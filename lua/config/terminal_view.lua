local M = {}
local views = {}

local function snapshot(win)
  if not vim.api.nvim_win_is_valid(win) then return end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= 'terminal' then return end
  local info = vim.fn.getwininfo(win)[1]
  local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  return {
    buf = buf, height = info.height, width = info.width, view = view,
    center = view.topline + (info.height - 1) / 2,
    anchor = view.topline == 1 and 'top'
      or (info.botline >= vim.api.nvim_buf_line_count(buf) and 'bottom' or 'center'),
  }
end

local function remember(win)
  local now = snapshot(win)
  local old = views[win]
  if now and old and old.buf == now.buf and old.view.topline == now.view.topline
    and old.height == now.height then
    now.center, now.anchor = old.center, old.anchor
  end
  -- Cursor events can arrive after the size changed but before WinScrolled.
  -- Keep the last viewport until the resize handler has used it.
  if not now or not old or old.buf ~= now.buf or (old.height == now.height and old.width == now.width) then
    views[win] = now
  end
end

local function resized(win)
  local now, old = snapshot(win), views[win]
  if not now then views[win] = nil; return end
  if not old or old.buf ~= now.buf or (old.height == now.height and old.width == now.width) then
    remember(win)
    return
  end
  local count = vim.api.nvim_buf_line_count(now.buf)
  local top
  if old.anchor == 'top' then
    top = 1
  elseif old.anchor == 'bottom' then
    top = count - now.height + 1
  else
    top = math.floor(old.center - (now.height - 1) / 2 + 0.5)
  end
  top = math.max(1, math.min(top, math.max(1, count - now.height + 1)))
  local view = vim.deepcopy(old.view)
  view.topline = top
  -- Keep the cursor if it still fits; otherwise move it just inside the view
  -- so Neovim does not scroll away from the requested anchor to reveal it.
  local margin = math.min(vim.wo[win].scrolloff, math.floor((now.height - 1) / 2))
  view.lnum = math.max(top + margin, math.min(view.lnum, top + now.height - 1 - margin, count))
  vim.api.nvim_win_call(win, function() vim.fn.winrestview(view) end)
  views[win] = snapshot(win)
  -- Clamping to a boundary does not mean the user scrolled to that boundary.
  views[win].center, views[win].anchor = old.center, old.anchor
end

function M.setup()
  local group = vim.api.nvim_create_augroup('ConfigTerminalView', { clear = true })
  vim.api.nvim_create_autocmd('WinScrolled', {
    group = group,
    callback = function()
      for key in pairs(vim.v.event) do
        local win = tonumber(key)
        if win then resized(win) end
      end
    end,
  })
  vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter', 'WinEnter', 'CursorMoved', 'TermEnter', 'TermLeave' }, {
    group = group, callback = function() remember(vim.api.nvim_get_current_win()) end,
  })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group, callback = function(event) views[tonumber(event.match)] = nil end,
  })
  for _, win in ipairs(vim.api.nvim_list_wins()) do remember(win) end
end

return M
