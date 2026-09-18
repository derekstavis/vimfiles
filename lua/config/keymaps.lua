local map = vim.keymap.set
local function nmap(lhs, rhs, desc) map('n', lhs, rhs, { silent = true, desc = desc }) end
map({ 'n', 'x', 'o' }, 'H', '^')
map({ 'n', 'x', 'o' }, 'L', '$')
map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')
map({ 'n', 'x', 'o' }, '<C-c>', '<Esc>')
nmap('<leader>tn', '<Cmd>tabnew<CR>', 'New tab')
nmap('<leader>th', '<Cmd>tabprevious<CR>', 'Previous tab')
nmap('<leader>tl', '<Cmd>tabnext<CR>', 'Next tab')
nmap('<leader>fs', function() MiniMisc.zoom() end, 'Toggle focused window')
nmap('<Space>', 'za', 'Toggle fold')
nmap('zO', 'zR', 'Open all folds')
nmap('<C-Space>', 'zM', 'Close all folds')
nmap('zf', 'mzzMzvzz', 'Close other folds')
-- Native incremental search; g/ restores the origin when the search completes.
map('n', 'g/', function()
  local win, pos = vim.api.nvim_get_current_win(), vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_create_autocmd('CmdlineLeave', {
    once = true,
    callback = function(event)
      if event.match == '/' then
        vim.schedule(function() pcall(vim.api.nvim_win_set_cursor, win, pos) end)
      end
    end,
  })
  return '/'
end, { expr = true, desc = 'Incremental search without moving' })
nmap('<leader>sc', function() vim.wo.spell = not vim.wo.spell end, 'Toggle spelling')
nmap('<leader>hs', function() vim.o.hlsearch = not vim.o.hlsearch end, 'Toggle search highlighting')
nmap('<leader>ll', function()
  vim.g.relative_numbers = not vim.g.relative_numbers
  vim.wo.relativenumber = vim.g.relative_numbers
end, 'Toggle relative numbers')
nmap('<leader>ev', function() vim.cmd.vsplit(vim.env.MYVIMRC) end, 'Edit configuration')
nmap('<leader>sv', function()
  for name in pairs(package.loaded) do
    if name:match('^config%.') then package.loaded[name] = nil end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify('Configuration reloaded')
end, 'Reload configuration')
nmap('<leader>xx', function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then return end
  local stat = vim.uv.fs_stat(path)
  if stat then
    local ok, err = vim.uv.fs_chmod(path, bit.bor(stat.mode, 73))
    if not ok then vim.notify(err, vim.log.levels.ERROR) end
  end
end, 'Make file executable')
nmap('<leader>q', '<Cmd>pclose<CR><Cmd>cclose<CR>', 'Close preview and quickfix')
nmap('<leader>l', function()
  if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then vim.cmd.lclose() else vim.cmd.lopen() end
end, 'Toggle location list')

for key, direction in pairs({ Left = 'h', Down = 'j', Up = 'k', Right = 'l' }) do
  nmap('<C-' .. key .. '>', '<C-w>' .. direction, 'Focus ' .. direction)
  map('t', '<C-' .. key .. '>', '<C-\\><C-n><C-w>' .. direction, { silent = true })
  nmap('<S-' .. key .. '>', function()
    local current = vim.fn.winnr()
    local horizontal = direction == 'h' or direction == 'l'
    local near = vim.fn.winnr(horizontal and 'h' or 'k') ~= current
    local far = vim.fn.winnr(horizontal and 'l' or 'j') ~= current
    if not near and not far then return end
    local grow = (direction == 'l' or direction == 'j') == far
    local amount = vim.v.count > 0 and vim.v.count or 8
    local action = horizontal and (grow and '>' or '<') or (grow and '+' or '-')
    vim.cmd.wincmd(tostring(amount) .. action)
  end, 'Resize toward ' .. direction)
end
for _, key in ipairs({ 'j', 'k' }) do
  map('n', key, function() return (vim.v.count >= 7 and "m'" or '') .. key end, { expr = true })
end

local marked_window
local function mark_window() marked_window = vim.api.nvim_get_current_win() end
local function swap_window()
  local current = vim.api.nvim_get_current_win()
  if not marked_window or not vim.api.nvim_win_is_valid(marked_window) then mark_window(); return end
  if marked_window == current then return end
  local a, b = vim.api.nvim_win_get_buf(current), vim.api.nvim_win_get_buf(marked_window)
  local av, bv = vim.fn.winsaveview(), vim.api.nvim_win_call(marked_window, vim.fn.winsaveview)
  vim.api.nvim_win_set_buf(current, b)
  vim.api.nvim_win_set_buf(marked_window, a)
  vim.fn.winrestview(bv)
  vim.api.nvim_win_call(marked_window, function() vim.fn.winrestview(av) end)
  marked_window = nil
end
nmap('<leader>ww', swap_window, 'Mark window / swap with marked window')
nmap('<leader>yw', mark_window, 'Mark window for swap')
nmap('<leader>pw', swap_window, 'Swap with marked window')

local function terminal(command)
  vim.cmd(command)
  vim.cmd.terminal(vim.fn.executable('fish') == 1 and vim.fn.exepath('fish') or vim.o.shell)
end
nmap('<leader>tsh', function() terminal('tabnew') end, 'Terminal tab')
nmap('<leader>vsh', function() require('config.terminal').new('right') end, 'New vertical terminal')
nmap('<leader>sh', function() require('config.terminal').new() end, 'New terminal in bottom panel')
nmap('<leader>3', function() require('config.terminal').toggle() end, 'Toggle terminal panel')
-- Remove the old cycling shortcuts when reloading a running session.
for _, lhs in ipairs({ '[t', ']t' }) do pcall(vim.keymap.del, 'n', lhs) end
map({ 'n', 'i', 'x' }, '<D-s>', '<Cmd>write<CR>', { desc = 'Save file' })
nmap('<leader>1', function()
  require('nvim-tree.api').tree.toggle({ find_file = true, focus = true })
end, 'Toggle file explorer')
nmap('<leader>2', '<Cmd>AerialToggle<CR>', 'Toggle symbol outline')
nmap('<C-p>', function() require('telescope.builtin').find_files() end, 'Find files')
nmap('<C-f>', function() require('telescope.builtin').live_grep() end, 'Search project')
nmap('<C-b>', function() require('telescope.builtin').buffers() end, 'Find buffer')
nmap('<leader>bp', function() require('dap').toggle_breakpoint() end, 'Toggle breakpoint')
nmap('<leader>rp', '<Cmd>DapNew<CR>', 'New debug session')
nmap('<leader>kp', function() require('dap').disconnect() end, 'Disconnect debugger')
-- Keep the original terminal keycodes (Ctrl-[ also encodes Escape).
nmap('<C-[>', function()
  if vim.bo.buftype == 'terminal' then require('config.terminal').cycle(-1)
  else require('dap').step_over() end
end, 'Previous terminal / debug step over')
nmap('<C-{>', function() require('dap').step_into() end, 'Debug step into')
nmap('<C-]>', function()
  if vim.bo.buftype == 'terminal' then require('config.terminal').cycle(1)
  else require('dap').step_out() end
end, 'Next terminal / debug step out')
nmap('<C-}>', function() require('dap').continue() end, 'Debug continue')
nmap('<leader>xb', [[<Cmd>%s/>[ \t]*</>\r</g<CR>gg=G]], 'Expand and indent XML')

vim.api.nvim_create_user_command('BD', function(opts) MiniBufremove.delete(0, opts.bang) end, { bang = true })
vim.api.nvim_create_user_command('StripWhitespace', MiniTrailspace.trim, {})
vim.api.nvim_create_user_command('Clear', function()
  local scrollback = vim.bo.scrollback
  vim.bo.scrollback = 1
  vim.bo.scrollback = scrollback
end, {})
vim.api.nvim_create_user_command('SaveSession', function(opts)
  if opts.args ~= '' then MiniSessions.write(opts.args); return end
  vim.ui.input({ prompt = 'Session name: ' }, function(name)
    if name and name ~= '' then MiniSessions.write(name) end
  end)
end, { nargs = '?' })
vim.api.nvim_create_user_command('LoadSession', function() MiniSessions.select('read') end, {})
vim.api.nvim_create_user_command('DeleteSession', function() MiniSessions.select('delete') end, {})
vim.api.nvim_create_user_command('GH', function(opts)
  vim.cmd(opts.line1 .. ',' .. opts.line2 .. 'GBrowse')
end, { range = true })
nmap('<leader>gh', '<Cmd>GH<CR>', 'Open file on GitHub')
map('x', '<leader>gh', ':GH<CR>', { desc = 'Open selection on GitHub' })
nmap('<leader>go', function()
  local url = vim.fn['rhubarb#HomepageForUrl'](vim.fn.FugitiveRemoteUrl())
  if url ~= '' then vim.ui.open(url) end
end, 'Open repository on GitHub')
vim.api.nvim_create_user_command('GB', function(opts)
  local file = vim.api.nvim_buf_get_name(0)
  local root = vim.fs.root(file, '.git')
  if not root then return end
  local result = vim.system({ 'git', 'rev-parse', 'HEAD' }, { cwd = root, text = true }):wait()
  if result.code ~= 0 then vim.notify(result.stderr, vim.log.levels.ERROR); return end
  local path = vim.fs.relpath(root, file)
  local url = vim.fn['rhubarb#FugitiveUrl']({
    remote = vim.fn.FugitiveRemoteUrl(), commit = vim.trim(result.stdout),
    path = path, type = 'blob', line1 = opts.line1, line2 = opts.line2,
  })
  if url ~= '' then vim.ui.open((url:gsub('/blob/', '/blame/', 1))) end
end, { range = true })
nmap('<leader>gb', '<Cmd>GB<CR>', 'Open GitHub blame')
map('x', '<leader>gb', ':GB<CR>', { desc = 'Open GitHub blame for selection' })
