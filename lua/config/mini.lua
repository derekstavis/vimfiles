local map = vim.keymap.set
require('mini.icons').setup()
require('mini.icons').mock_nvim_web_devicons()
require('mini.bufremove').setup()
require('mini.misc').setup()
require('mini.splitjoin').setup({ mappings = { toggle = '', split = '', join = '' } })
for key, action in pairs({ gS = 'split', gJ = 'join' }) do
  map('n', key, function()
    if MiniSplitjoin[action]() then return end
    -- splitjoin.vim also worked with the cursor before the opening bracket.
    local pos = vim.api.nvim_win_get_cursor(0)
    local col = vim.api.nvim_get_current_line():find('[%(%[%{]', pos[2] + 1)
    if col then MiniSplitjoin[action]({ position = { line = pos[1], col = col } }) end
  end, { desc = action .. ' arguments' })
end
require('mini.surround').setup({
  mappings = {
    add = 'ys', delete = 'ds', replace = 'cs', find = '', find_left = '',
    highlight = '', suffix_last = '', suffix_next = '',
  },
  search_method = 'cover_or_next',
})
map('n', 'yss', 'ys_', { remap = true, desc = 'Surround line' })
vim.keymap.del('x', 'ys')
map('x', 'S', ":<C-u>lua MiniSurround.add('visual')<CR>", { silent = true, desc = 'Surround selection' })
require('mini.comment').setup({
  mappings = { comment = 'gc', comment_line = 'gcc', comment_visual = 'gc', textobject = 'gc' },
})
map({ 'n', 'x' }, '<C-_>', 'gc', { remap = true, desc = 'Toggle comment' })
map('n', '<C-_><C-_>', 'gcc', { remap = true, desc = 'Toggle line comment' })
map('n', 'gcb', 'gcc', { remap = true, desc = 'Toggle line comment' })

require('mini.bracketed').setup({
  -- Only replace the history/yank tools; leave other existing keys alone.
  buffer = { suffix = '' }, comment = { suffix = '' }, conflict = { suffix = '' },
  diagnostic = { suffix = '' }, file = { suffix = '' }, indent = { suffix = '' },
  jump = { suffix = '' }, location = { suffix = '' }, oldfile = { suffix = '' },
  quickfix = { suffix = '' }, treesitter = { suffix = '' }, undo = { suffix = '' },
  window = { suffix = '' }, yank = { suffix = '' },
})
for _, key in ipairs({ 'p', 'P' }) do
  map('n', key, function() return MiniBracketed.register_put_region(key) end, { expr = true })
end
map('n', '<CR>', function() MiniBracketed.yank('backward') end, { desc = 'Older yank over last paste' })
map('n', '<BS>', function() MiniBracketed.yank('forward') end, { desc = 'Newer yank over last paste' })
map('n', '<leader><Left>', function() MiniBracketed.oldfile('backward') end, { desc = 'Previous visited file' })
map('n', '<leader><Right>', function() MiniBracketed.oldfile('forward') end, { desc = 'Next visited file' })

require('mini.trailspace').setup()
local hipatterns = require('mini.hipatterns')
hipatterns.setup({ highlighters = { hex_color = hipatterns.gen_highlighter.hex_color() } })
require('mini.sessions').setup({ autoread = false, autowrite = false, file = '' })
require('mini.snippets').setup({
  snippets = { require('mini.snippets').gen_loader.from_lang({ lang_patterns = {
    javascriptreact = { 'javascript.json' }, typescriptreact = { 'javascript.json' },
  } }) },
})
require('mini.completion').setup()
local input = require('mini.input')
local default_input_view = input.gen_view.floatwin()
local rename_input_view = input.gen_view.floatwin({ style = 'TL' })
local function is_tree_rename(opts)
  return vim.bo.filetype == 'NvimTree' and opts.prompt == 'Rename to '
end
input.setup({ handlers = { view = function(state)
  local view = is_tree_rename(state.opts) and rename_input_view or default_input_view
  return view(state)
end } })
vim.ui.input = function(opts, on_confirm)
  opts = opts or {}
  if is_tree_rename(opts) then
    opts = vim.tbl_extend('force', opts, { scope = 'cursor' })
  end
  MiniInput.ui_input(opts, on_confirm)
end
require('mini.pick').setup()
vim.ui.select = MiniPick.ui_select
