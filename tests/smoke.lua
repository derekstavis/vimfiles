-- Run after normal startup: nvim --headless -c 'luafile tests/smoke.lua'
local function run()
  assert(package.loaded['config.autocmds'], 'Configuration did not finish loading')
  local function lines() return vim.api.nvim_buf_get_lines(0, 0, -1, false) end
  local function buffer(text)
    vim.cmd.enew()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, text)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end
  local function keys(text)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(text, true, false, true), 'xt', false)
  end
  local function mapping(lhs)
    local result = vim.fn.maparg(lhs, 'n', false, true)
    assert(result.callback, 'Missing callback: ' .. lhs)
    return result.callback
  end

  buffer({ 'word' })
  keys('ysiw)')
  assert(lines()[1] == '(word)', 'ysiw must retain surround behavior')
  keys('cs)]')
  assert(lines()[1] == '[word]', 'cs must replace a surrounding')
  keys('ds]')
  assert(lines()[1] == 'word', 'ds must delete a surrounding')
  keys('viwS]')
  assert(lines()[1] == '[word]', 'Visual S must surround the selection')

  buffer({ '<root><child>value</child></root>' })
  vim.bo.filetype = 'xml'
  keys(',xb')
  assert(#lines() == 3, 'XML expansion must split adjacent tags')

  buffer({ 'local answer = 42' })
  vim.bo.filetype = 'lua'
  keys('gcc')
  assert(lines()[1]:match('^%-%-'), 'gcc must comment a line')
  keys('gcc')
  assert(lines()[1] == 'local answer = 42', 'gcc must uncomment a line')

  buffer({ 'call(one, two)' })
  keys('gS')
  assert(#lines() > 1, 'gS must split arguments')
  keys('gJ')
  assert(lines()[1] == 'call(one, two)', 'gJ must join arguments')

  buffer({ 'first', 'second', 'destination' })
  keys('yyjyyjp')
  assert(lines()[4] == 'second', 'p must paste the latest yank')
  keys('<CR>')
  assert(lines()[4] == 'first', 'Enter must cycle to the older yank')
  keys('<BS>')
  assert(lines()[4] == 'second', 'Backspace must cycle to the newer yank')

  buffer({ '  keep  ', 'also keep\t' })
  vim.cmd.StripWhitespace()
  assert(vim.deep_equal(lines(), { '  keep', 'also keep' }), 'Trim must preserve leading whitespace')

  buffer({ 'left' })
  local left = vim.api.nvim_get_current_win()
  vim.cmd.vnew()
  local right = vim.api.nvim_get_current_win()
  local deleted = vim.api.nvim_get_current_buf()
  local count = #vim.api.nvim_tabpage_list_wins(0)
  vim.cmd.BD()
  assert(#vim.api.nvim_tabpage_list_wins(0) == count, 'BD must preserve splits')
  assert(not vim.bo[deleted].buflisted, 'BD must unlist the deleted buffer')
  vim.api.nvim_set_current_win(left)
  local width = vim.api.nvim_win_get_width(left)
  mapping('<S-Right>')()
  assert(vim.api.nvim_win_get_width(left) > width, 'Shift-Right must move the split boundary right')
  local a, b = vim.api.nvim_win_get_buf(left), vim.api.nvim_win_get_buf(right)
  mapping(',yw')()
  vim.api.nvim_set_current_win(right)
  mapping(',pw')()
  assert(vim.api.nvim_win_get_buf(left) == b and vim.api.nvim_win_get_buf(right) == a, 'Window swap must swap buffers')

  local temp = vim.fn.tempname()
  vim.fn.mkdir(temp, 'p')
  vim.fn.writefile({ 'content' }, temp .. '/example.uvml')
  vim.cmd.edit(temp .. '/example.uvml')
  assert(vim.bo.filetype == 'uvml', 'UVML filetype must survive migration')
  local tree = require('nvim-tree.api').tree
  tree.open({ path = temp, find_file = true })
  assert(tree.is_visible(), 'Explorer must open')
  local entry = tree.get_node_under_cursor()
  assert(entry and entry.name == 'example.uvml', 'Explorer must list files')
  assert(vim.fn.maparg('ev', 'n', false, true).buffer == 1, 'Explorer split keys must be local')
  require('nvim-tree-preview').unwatch()
  tree.close()

  vim.cmd.edit(temp .. '/example.md')
  assert(vim.bo.filetype == 'markdown' and vim.wo.wrap, 'Markdown must use native filetype and wrap')
  vim.cmd.edit(temp .. '/example.txt')
  assert(not vim.wo.wrap, 'Markdown options must not leak to other files')

  local js = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath('config') .. '/snippets/javascript.json'), '\n'))
  MiniSnippets.parse(js['JSX element'].body)
  MiniSnippets.parse(js.Timeout.body)
  local packages = vim.pack.get()
  assert(#packages == 27, 'Expected all declared packages to be installed')
  for _, package in ipairs(packages) do assert(package.active, package.spec.name .. ' was not loaded') end
  assert(vim.fn.exists(':Git') == 2 and vim.fn.exists(':DapNew') == 2, 'Git and debugger commands must remain available')
  assert(vim.fn.exists(':CocInfo') == 0 and vim.fn.exists(':PlugInstall') == 0, 'Legacy managers must not load')
  vim.fn.delete(temp, 'rf')
  print('PASS: startup, editing, yank history, splits, explorer, filetypes, snippets, packages')
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd.cquit({ args = { '1' } })
else
  vim.cmd('qa!')
end
