local group = vim.api.nvim_create_augroup('ConfigPackages', { clear = true })
vim.api.nvim_create_autocmd('PackChanged', {
  group = group,
  callback = function(event)
    local data = event.data
    if data.kind ~= 'install' and data.kind ~= 'update' then return end
    if data.spec.name == 'nvim-treesitter' and data.kind == 'update' then
      vim.schedule(function()
        require('config.treesitter').update()
      end)
    end
  end,
})

-- These two retain workflows without a close mini.nvim equivalent.
vim.g.VM_maps = {
  ['Add Cursor Down'] = '<A-Down>', ['Add Cursor Up'] = '<A-Up>',
  ['Select l'] = '', ['Select h'] = '',
}
-- VM's startup map builder only accepts permanent mappings. Its buffer map
-- builder reads these later, when a multi-cursor session starts.
local function configure_vm_buffer_maps()
  local maps = vim.g.VM_maps
  maps.Undo, maps.Redo = 'u', '<C-r>'
  vim.g.VM_maps = maps
end
if vim.v.vim_did_enter == 1 then
  configure_vm_buffer_maps()
else
  vim.api.nvim_create_autocmd('VimEnter', { group = group, once = true, callback = configure_vm_buffer_maps })
end

vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim', version = 'stable' },
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/b0o/nvim-tree-preview.lua',
  'https://github.com/ellisonleao/gruvbox.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/stevearc/aerial.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/stevearc/conform.nvim',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/HiPhish/rainbow-delimiters.nvim',
  'https://github.com/m4xshen/smartcolumn.nvim',
  'https://github.com/RaafatTurki/hex.nvim',
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-rhubarb',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/mg979/vim-visual-multi',
  'https://github.com/wakatime/vim-wakatime',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/zbirenbaum/copilot.lua',
  'https://github.com/jellydn/tiny-term.nvim',
}, { confirm = false })

vim.api.nvim_create_user_command('PackUpdate', function() vim.pack.update() end, {})
