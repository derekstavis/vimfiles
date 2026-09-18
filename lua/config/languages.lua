local map = vim.keymap.set
require('mason').setup()
vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })

-- nvim-lspconfig supplies server definitions; Neovim owns activation.
local servers = {
  lua_ls = { settings = { Lua = {
    runtime = { version = 'LuaJIT' }, diagnostics = { globals = { 'vim' } },
    workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    telemetry = { enable = false },
  } } },
  ts_ls = { settings = {
    typescript = { inlayHints = { includeInlayParameterNameHints = 'all' }, preferences = { quoteStyle = 'double' } },
    javascript = { inlayHints = { includeInlayParameterNameHints = 'all' } },
  }, init_options = { maxTsServerMemory = 16000 } },
  rust_analyzer = { settings = { ['rust-analyzer'] = { inlayHints = { parameterHints = { enable = true } } } } },
  cssls = {}, html = {}, jsonls = {}, yamlls = {}, taplo = {}, marksman = {},
  pyright = {}, gopls = {}, hls = {}, eslint = {}, biome = {},
}
local node_commands = {
  ts_ls = 'typescript-language-server', eslint = 'vscode-eslint-language-server', biome = 'biome',
  cssls = 'vscode-css-language-server', html = 'vscode-html-language-server',
  jsonls = 'vscode-json-language-server', yamlls = 'yaml-language-server',
}
for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  -- Missing tools stay quiet. Install through :Mason, then restart Neovim.
  local cmd = vim.lsp.config[name].cmd
  local executable = node_commands[name] or cmd[1]
  if vim.fn.executable(executable) == 1 or vim.fn.executable('node_modules/.bin/' .. executable) == 1 then
    vim.lsp.enable(name)
  end
end

vim.api.nvim_create_user_command('InstallTools', function()
  -- 5.1.3 supports the existing Node 22.16 installation; 6.x needs 22.22.2+.
  vim.cmd('MasonInstall --quiet typescript-language-server@5.1.3 rust-analyzer css-lsp html-lsp json-lsp yaml-language-server taplo marksman pyright lua-language-server eslint-lsp biome prettier black goimports gopls codelldb')
  vim.notify('Installing language and debugging tools. Restart Neovim after Mason finishes.')
end, {})

vim.diagnostic.config({ severity_sort = true, float = { border = 'rounded', source = true } })
vim.lsp.on_type_formatting.enable()
local group = vim.api.nvim_create_augroup('ConfigLsp', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end
    local buf = event.buf
    if client:supports_method('textDocument/inlayHint') then vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end
    if client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_autocmd('CursorHold', { group = group, buffer = buf, callback = vim.lsp.buf.document_highlight })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter' }, { group = group, buffer = buf, callback = vim.lsp.buf.clear_references })
    end
    if client:supports_method('textDocument/codeLens') then
      vim.lsp.codelens.enable(true, { bufnr = buf })
    end
  end,
})

local conform = require('conform')
local function web_formatter(buf)
  if vim.fs.root(buf, { 'biome.json', 'biome.jsonc' }) then return { 'biome' } end
  return { 'prettier' }
end
conform.setup({
  formatters_by_ft = {
    javascript = web_formatter, javascriptreact = web_formatter,
    typescript = web_formatter, typescriptreact = web_formatter,
    json = web_formatter, jsonc = web_formatter, css = web_formatter,
    html = { 'prettier' }, markdown = { 'prettier' }, yaml = { 'prettier' },
    python = { 'black' }, go = { 'goimports', 'gofmt' }, terraform = { 'terraform_fmt' },
  },
  format_on_save = function(buf)
    local ft = vim.bo[buf].filetype
    if vim.tbl_contains({ 'rust', 'css', 'markdown', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'go', 'terraform' }, ft) then
      return { timeout_ms = 3000, lsp_format = 'fallback' }
    end
  end,
})
local function format() conform.format({ async = true, lsp_format = 'fallback' }) end
vim.api.nvim_create_user_command('Format', function(opts)
  local range
  if opts.range > 0 then
    range = { start = { opts.line1, 0 }, ['end'] = { opts.line2, #vim.fn.getline(opts.line2) } }
  end
  conform.format({ async = true, lsp_format = 'fallback', range = range })
end, { range = true })
vim.api.nvim_create_user_command('Fold', function()
  vim.wo.foldmethod = 'expr'
  vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
  vim.cmd.normal({ 'zx', bang = true })
end, {})

map('n', 'gd', vim.lsp.buf.definition, { desc = 'Definition' })
map('n', 'gt', vim.lsp.buf.type_definition, { desc = 'Type definition' })
map('n', 'gi', vim.lsp.buf.implementation, { desc = 'Implementation' })
map('n', 'gr', function() require('telescope.builtin').lsp_references() end, { desc = 'References' })
map('n', 'K', function()
  if vim.bo.filetype == 'vim' or vim.bo.filetype == 'help' then
    vim.cmd.help(vim.fn.expand('<cword>'))
  else
    vim.lsp.buf.hover({ border = 'rounded', max_height = 30 })
  end
end, { desc = 'Documentation' })
map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
map({ 'n', 'x' }, '<leader>f', format, { desc = 'Format buffer or selection' })
map('n', '<leader>pp', format, { desc = 'Format buffer' })
map({ 'n', 'x' }, '<leader>vca', vim.lsp.buf.code_action, { desc = 'Selection code actions' })
map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
map('n', '<leader>qf', function()
  vim.lsp.buf.code_action({ context = { only = { 'quickfix' } }, apply = true })
end, { desc = 'Quick fix' })
map('n', '<leader>[', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous diagnostic' })
map('n', '<leader>]', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next diagnostic' })
map('n', '<leader>wtf', vim.diagnostic.open_float, { desc = 'Diagnostic details' })
map('n', '<leader>d', function() require('telescope.builtin').diagnostics() end, { desc = 'All diagnostics' })
map('n', '<leader>o', function() require('telescope.builtin').lsp_document_symbols() end, { desc = 'Document symbols' })
map('n', '<leader>s', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, { desc = 'Workspace symbols' })
map('n', '<leader>c', function() require('telescope.builtin').commands() end, { desc = 'Commands' })
map('n', '<leader>p', function() require('telescope.builtin').resume() end, { desc = 'Resume picker' })
map('n', '<leader>e', '<Cmd>Mason<CR>', { desc = 'Language tools' })
map('n', '<leader>m', '<Cmd>Mason<CR>', { desc = 'Install language tools' })

map('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then return '<C-n>' end
  local before = vim.api.nvim_get_current_line():sub(1, vim.fn.col('.') - 1)
  if before == '' or before:match('%s$') then return '<Tab>' end
  MiniCompletion.complete_twostage()
  return ''
end, { expr = true, desc = 'Complete or indent' })
map('i', '<S-Tab>', function() return vim.fn.pumvisible() == 1 and '<C-p>' or '<C-h>' end, { expr = true })
map('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then return '<C-y>' end
  return '<C-g>u<CR>'
end, { expr = true })

vim.filetype.add({
  extension = { uvml = 'uvml', cjsx = 'coffee', pp = 'puppet', ejs = 'html', ls = 'ls', lookml = 'yaml' },
  filename = { Puppetfile = 'ruby' }, pattern = { ['Rockerfile.*'] = 'dockerfile' },
})
