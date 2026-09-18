local opt = vim.opt
opt.shell = 'sh'
opt.termguicolors = true
opt.background = 'dark'
opt.eadirection = 'hor'
opt.showcmd = false
opt.showmode = true
opt.sessionoptions:remove('buffers')
opt.hidden = true
opt.ignorecase = true
opt.smartcase = true
opt.number = true
opt.relativenumber = true
if vim.g.relative_numbers == nil then vim.g.relative_numbers = true end
opt.ruler = true
opt.colorcolumn = '72'
opt.cursorline = true
opt.incsearch = true
opt.hlsearch = false
opt.inccommand = 'split'
opt.wrap = false
opt.scrolloff = 3
opt.title = true
opt.titlestring = '%t'
opt.visualbell = false
opt.scrollback = 65535
opt.backup = false
opt.writebackup = false
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.foldlevelstart = 50
opt.foldmethod = 'indent'
opt.laststatus = 2
opt.diffopt:append('vertical')
opt.autoread = true
opt.fillchars:append({ eob = ' ', vert = '│' })
opt.splitbelow = true
opt.splitright = true
opt.cmdheight = 2
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.updatetime = 300
opt.shortmess:append('c')
opt.signcolumn = 'yes'
opt.spelllang = 'en_us'
opt.clipboard = 'unnamedplus'
opt.guifont = 'Fira Code:h12'

local swap = vim.fn.stdpath('state') .. '/swap'
vim.fn.mkdir(swap, 'p')
opt.directory = swap .. '//'

-- Built-in EditorConfig and trust-gated .nvim.lua/.nvimrc support.
vim.g.editorconfig = true
opt.exrc = true
vim.g.omni_sql_no_default_maps = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
