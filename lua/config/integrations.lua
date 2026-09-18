local gruvbox = require('gruvbox')
gruvbox.setup({
  contrast = 'hard',
  overrides = {
    TinyTermNormal = { fg = gruvbox.palette.light1, bg = gruvbox.palette.dark0_hard },
    ExplorerPreviewNormal = { fg = gruvbox.palette.light1, bg = gruvbox.palette.dark0 },
    ExplorerPreviewTitle = { fg = gruvbox.palette.light1, bg = gruvbox.palette.dark0, bold = true },
  },
})
vim.cmd.colorscheme('gruvbox')
require('telescope').setup({
  defaults = {
    layout_strategy = 'horizontal', sorting_strategy = 'ascending', winblend = 0,
    layout_config = {
      anchor = 'N', prompt_position = 'top', horizontal = { preview_width = 0.6 },
      height = 0.5, width = 0.6,
    },
    file_ignore_patterns = { '%.git/' },
  },
  pickers = { find_files = { hidden = true } },
})
require('aerial').setup({ layout = { min_width = 30, default_direction = 'right' } })
require('lualine').setup({
  options = {
    theme = 'gruvbox_dark', icons_enabled = true, globalstatus = false,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { 'NvimTree', 'aerial', 'tiny_term', 'terminal' },
    ignore_focus = { 'NvimTree', 'aerial' },
    refresh = { statusline = 100, tabline = 100, winbar = 100 },
  },
  sections = {
    lualine_a = { { 'mode', fmt = function(str) return str:sub(1, 1) end } },
    lualine_b = {
      { function()
        local icon = MiniIcons.get('file', vim.api.nvim_buf_get_name(0))
        return icon .. ' ' .. (vim.b.term_title or vim.fn.expand('%:t')) .. (vim.bo.modified and ' ●' or '')
      end },
      { 'location', cond = function() return vim.bo.buftype ~= 'terminal' end },
    },
    lualine_c = {}, lualine_x = { 'aerial' }, lualine_y = {}, lualine_z = { 'branch' },
  },
})
require('smartcolumn').setup({ colorcolumn = '72', disabled_filetypes = { 'help', 'text', 'markdown', 'NvimTree', 'aerial' } })
require('hex').setup()
require('render-markdown').setup()
require('copilot').setup({
  suggestion = { auto_trigger = true, keymap = { accept = '<C-Return>' } },
})

local dap, dapui = require('dap'), require('dapui')
dapui.setup()
require('nvim-dap-virtual-text').setup()
dap.listeners.before.attach.config = function() dapui.open() end
dap.listeners.before.launch.config = function() dapui.open() end
dap.listeners.before.event_terminated.config = function() dapui.close() end
dap.listeners.before.event_exited.config = function() dapui.close() end

-- Installation is explicit so opening the editor never compiles parsers.
vim.api.nvim_create_user_command('InstallParsers', function()
  require('config.treesitter').install()
end, {})
vim.api.nvim_create_user_command('UpdateParsers', function()
  require('config.treesitter').update()
end, {})
