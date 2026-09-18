local api = require('nvim-tree.api')
local preview = require('nvim-tree-preview')
preview.unwatch()
if vim.g.explorer_previews == nil then vim.g.explorer_previews = true end

local function dismiss_preview()
  vim.g.explorer_previews = false
  preview.unwatch()
end
preview.setup({
  border = 'none', show_title = false,
  -- Keep previews below help and other ordinary floating windows (layer 50).
  zindex = 40,
  on_open = function(win)
    vim.wo[win].winhighlight = 'Normal:ExplorerPreviewNormal,NormalFloat:ExplorerPreviewNormal,NormalNC:ExplorerPreviewNormal,EndOfBuffer:ExplorerPreviewNormal,WinBar:ExplorerPreviewTitle,WinBarNC:ExplorerPreviewTitle'
    vim.wo[win].winblend = 0
    vim.wo[win].cursorline = false
  end,
  keymaps = { ['<Esc>'] = dismiss_preview },
})

-- The extension's default positioning reads the removed nvim-tree.config API.
-- Use live window geometry for both new previews and existing ones on resize.
local Preview = require('nvim-tree-preview.preview')
local layout = require('config.explorer_preview')
Preview.config_open = Preview.config_open or Preview.open
function Preview:open(node)
  local is_file = node.type == 'file'
  if node.type == 'link' then
    local target = vim.uv.fs_stat(node.absolute_path)
    is_file = target and target.type == 'file'
  end
  if not is_file then
    self:close({ focus_tree = false })
    return
  end
  return self:config_open(node)
end
Preview.config_get_win = Preview.config_get_win or Preview.get_win
function Preview:get_win()
  if not layout.bounds(api.tree.winid()) then
    if self:is_valid() then self:close({ focus_tree = false }) end
    return
  end
  local win = self:config_get_win()
  if win then self:update_title() end
  return win
end
function Preview:update_title()
  if not self:is_valid() then return end
  local title = self.tree_node.name
  vim.wo[self.preview_win].winbar = ' ' .. title:gsub('%%', '%%%%'):gsub('%c', ' ') .. ' '
end
function Preview:calculate_win_position(tree_win)
  local bounds = assert(layout.bounds(tree_win))
  return { row = bounds.row, col = bounds.col }
end
function Preview:calculate_win_size()
  local bounds = assert(layout.bounds(api.tree.winid()))
  return { width = bounds.width, height = bounds.height }
end

require('nvim-tree').setup({
  view = { side = 'left', width = 32, float = { enable = false } },
  renderer = { group_empty = false, indent_markers = { enable = true } },
  filters = { dotfiles = false, git_ignored = false },
  update_focused_file = { enable = true, update_root = false },
  actions = { open_file = { quit_on_open = false, window_picker = { enable = false } } },
  on_attach = function(buf)
    api.map.on_attach.default(buf)
    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end
    -- Remove single-key mappings that would swallow our dd/df and yy/yp/yn.
    for _, key in ipairs({ 'd', 'y' }) do pcall(vim.keymap.del, 'n', key, { buffer = buf }) end
    map('h', api.node.navigate.parent_close, 'Collapse directory / go to parent')
    map('l', function()
      local node = api.tree.get_node_under_cursor()
      if node and (node.type ~= 'directory' or not node.open) then api.node.open.edit() end
    end, 'Expand directory / open file')
    map('e', api.node.open.edit, 'Open file / toggle directory')
    map('es', api.node.open.horizontal, 'Open in split')
    map('ev', api.node.open.vertical, 'Open in vertical split')
    map('et', api.node.open.tab, 'Open in tab')
    map('yp', api.fs.copy.absolute_path, 'Copy file path')
    map('yn', api.fs.copy.filename, 'Copy filename')
    map('yy', api.fs.copy.node, 'Copy file')
    map('dd', api.fs.cut, 'Cut file')
    map('df', api.fs.remove, 'Delete file')
    map('zh', api.filter.dotfiles.toggle, 'Toggle hidden files')
    map('g.', api.filter.dotfiles.toggle, 'Toggle hidden files')
    map('gl', api.tree.expand_all, 'Expand tree recursively')
    map('gh', api.tree.collapse_all, 'Collapse tree')
    map('gs', function() api.tree.find_file({ focus = true }) end, 'Reveal current file')
    map('?', api.tree.toggle_help, 'Explorer help')
    map('<Tab>', function() preview.node_under_cursor({ toggle_focus = true }) end, 'Preview / focus preview')
    map('P', function()
      vim.g.explorer_previews = not vim.g.explorer_previews
      if vim.g.explorer_previews then
        if not preview.is_watching() then preview.watch() end
      else
        preview.unwatch()
      end
    end, 'Toggle automatic previews')
    map('<Esc>', dismiss_preview, 'Dismiss previews')
    map('<C-f>', function() preview.scroll(4) end, 'Scroll preview down')
    map('<C-b>', function() preview.scroll(-4) end, 'Scroll preview up')
  end,
})

local group = vim.api.nvim_create_augroup('ConfigExplorer', { clear = true })
vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
  group = group,
  callback = function()
    vim.schedule(function()
      local instance = require('nvim-tree-preview.manager').instance
      if instance and instance:is_valid() then instance:get_win() end
    end)
  end,
})
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  group = group,
  callback = function()
    if vim.bo.filetype ~= 'NvimTree' then return end
    vim.schedule(function()
      if vim.bo.filetype == 'NvimTree' and vim.g.explorer_previews
        and not preview.is_watching() and api.tree.get_node_under_cursor() then
        preview.watch()
      end
    end)
  end,
})
