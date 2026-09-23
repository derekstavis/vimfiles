local M = {}
local windows = require('tiny-term.window')
local terminals = require('tiny-term.terminal')
local shell_icon = MiniIcons.get('filetype', 'sh')
local statusline = "%!v:lua.require'config.terminal_tabs'.render()"

local function nonempty(value)
  return type(value) == 'string' and value ~= '' and value or nil
end

function M.label(buf, term)
  local label = nonempty(vim.b[buf].neordr_label)
  if label then return label end
  -- Shells and applications report their current title via OSC 0/2. The cwd
  -- and launch command persist while other programs run, so use them as fallbacks.
  local title = nonempty(vim.b[buf].term_title)
  if title then return title end
  local cwd = nonempty(vim.b[buf].osc7_dir)
  if cwd then return nonempty(vim.fs.basename(cwd:gsub('/+$', ''))) or '/' end

  local program = nonempty(vim.b[buf].term_program) or (term and term.cmd)
  if not program and vim.bo[buf].channel > 0 then
    program = vim.api.nvim_get_chan_info(vim.bo[buf].channel).argv
  end
  if type(program) == 'table' then program = program[1]
  elseif nonempty(program) then program = require('tiny-term').parse(program)[1] end
  if nonempty(program) then return vim.fs.basename(program) end
  return 'shell'
end

local function display_label(buf, term)
  return vim.fn.strcharpart(M.label(buf, term), 0, 24):gsub('%%', '%%%%'):gsub('%c', ' ')
end

local function highlights()
  local theme = require('lualine.themes.gruvbox_dark').normal
  local colors = { Active = theme.a, Inactive = theme.b, Fill = theme.c }
  for name, color in pairs(colors) do
    vim.api.nvim_set_hl(0, 'TerminalTabs' .. name, {
      fg = color.fg, bg = color.bg, bold = name == 'Active',
    })
    for next_name, next_color in pairs(colors) do
      vim.api.nvim_set_hl(0, 'TerminalTabs' .. name .. 'To' .. next_name, {
        fg = color.bg, bg = next_color.bg,
      })
    end
  end
end

function M.render()
  local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
  local ids = windows.get_split_terminals(win)
  local active = vim.w[win].tiny_term_id
  local parts = {}
  if #ids == 0 then
    return ('%%#TerminalTabsInactive# %s %s %%=%%#TerminalTabsFill#'):format(
      shell_icon, display_label(vim.api.nvim_win_get_buf(win)))
  end
  for index, id in ipairs(ids) do
    local term = terminals.get(id)
    if term then
      local style = id == active and 'Active' or 'Inactive'
      local next_style = index == #ids and 'Fill' or (ids[index + 1] == active and 'Active' or 'Inactive')
      local label = display_label(term.buf, term)
      parts[#parts + 1] = ('%%#TerminalTabs%s#%%%d@v:lua.TinyTermTabClick@ %d %s %s %%T'):format(style, index, index, shell_icon, label)
      parts[#parts + 1] = ('%%%d@v:lua.TinyTermTabCloseClick@ ✕ %%T'):format(index)
      parts[#parts + 1] = style == next_style and ('%%#TerminalTabs%s#'):format(style)
        or ('%%#TerminalTabs%sTo%s#'):format(style, next_style)
    end
  end
  parts[#parts + 1] = '%#TerminalTabsFill#%='
  return table.concat(parts)
end

function M.apply(win)
  if not vim.api.nvim_win_is_valid(win) then return end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype == 'terminal' and vim.bo[buf].filetype == '' then
    vim.bo[buf].filetype = 'terminal'
  end
  if vim.bo[buf].filetype == 'tiny_term' then
    vim.wo[win].winbar = ''
    vim.wo[win].statusline = statusline
  elseif vim.bo[buf].buftype == 'terminal' and vim.bo[buf].filetype == 'terminal' then
    vim.wo[win].winbar = ''
    vim.wo[win].statusline = statusline
  end
end

function M.setup()
  highlights()
  -- Disabled filetypes still let lualine clear a window's cached statusline.
  -- Return our terminal line on every refresh, including after buffer switches.
  local lualine = require('lualine')
  lualine.config_terminal_original_statusline = lualine.config_terminal_original_statusline or lualine.statusline
  local original_statusline = lualine.config_terminal_original_statusline
  lualine.statusline = function(...)
    if vim.bo.buftype == 'terminal' then return statusline end
    return original_statusline(...)
  end
  -- The plugin recreates its top winbar when opening or selecting a terminal.
  -- Replace it immediately, retaining its tab registry and click handlers.
  windows.config_tabline_originals = windows.config_tabline_originals or {
    stack_in_split = windows.stack_in_split, switch_to_terminal = windows.switch_to_terminal,
  }
  local originals = windows.config_tabline_originals
  windows.stack_in_split = function(...)
    local win = originals.stack_in_split(...)
    M.apply(win)
    return win
  end
  windows.switch_to_terminal = function(win, id)
    originals.switch_to_terminal(win, id)
    M.apply(win)
  end

  local group = vim.api.nvim_create_augroup('ConfigTerminalTabs', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = highlights })
  vim.api.nvim_create_autocmd('TermRequest', {
    group = group,
    callback = function(event)
      -- OSC 7 reports the shell's live cwd; it must not change Neovim's cwd.
      local path = event.data.sequence:match('^\027%]7;file://[^/]*(/.*)')
      if not path then return end
      path = path:gsub('\027\\$', ''):gsub('\007$', '')
      vim.b[event.buf].osc7_dir = path:gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end)
      vim.schedule(function() vim.cmd.redrawstatus() end)
    end,
  })
  vim.api.nvim_create_autocmd('TermOpen', {
    group = group,
    callback = function()
      M.apply(vim.api.nvim_get_current_win())
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    group = group, callback = function() M.apply(vim.api.nvim_get_current_win()) end,
  })
  for _, win in ipairs(vim.api.nvim_list_wins()) do M.apply(win) end
end

return M
