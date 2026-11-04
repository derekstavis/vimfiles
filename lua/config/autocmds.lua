local group = vim.api.nvim_create_augroup('ConfigAutocmds', { clear = true })
local function autocmd(events, opts)
  opts.group = group
  vim.api.nvim_create_autocmd(events, opts)
end
local check_pending = false
autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'InsertLeave', 'TermLeave', 'TermClose' }, {
  desc = 'Reload externally changed files and synchronize attached language servers',
  callback = function()
    if check_pending then return end
    check_pending = true
    vim.schedule(function()
      -- Avoid reloads or conflict prompts while typing or using a command window.
      if vim.api.nvim_get_mode().mode ~= 'n' or vim.fn.getcmdwintype() ~= '' then
        check_pending = false
        return
      end
      -- Check every loaded file, including hidden dependencies. 'autoread'
      -- preserves unsaved edits; the native LSP client handles buffer reloads.
      -- A bare :checktime can skip hidden buffers on this Neovim version.
      local ok, err = pcall(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == ''
            and vim.api.nvim_buf_get_name(buf) ~= '' then
            vim.cmd.checktime(tostring(buf))
          end
        end
      end)
      check_pending = false
      if not ok then error(err) end
    end)
  end,
})
autocmd('TextYankPost', { callback = function() vim.hl.on_yank({ timeout = 200 }) end })
autocmd('ModeChanged', {
  pattern = '*:n',
  desc = 'Finish snippet editing when returning to Normal mode',
  callback = function()
    -- The default only stops at $0, leaving argument decorations after Escape.
    -- End suspended outer snippets too when a completion was nested.
    while MiniSnippets.session.get() do MiniSnippets.session.stop() end
  end,
})
autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  callback = function()
    if vim.wo.number and vim.bo.buftype == '' and vim.fn.mode() ~= 'i' then
      vim.wo.relativenumber = vim.g.relative_numbers
    end
  end,
})
autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  callback = function() vim.wo.relativenumber = false end,
})
autocmd('TermOpen', { callback = function() vim.wo.signcolumn = 'no' end })
autocmd('BufLeave', { pattern = 'term://*', callback = function() vim.cmd.stopinsert() end })
autocmd('FileType', {
  pattern = { 'gitcommit', 'gitrebase', 'gitconfig' },
  callback = function() vim.bo.bufhidden = 'delete' end,
})
autocmd('FileType', { pattern = 'eruby', callback = function() vim.bo.shiftwidth = 4; vim.bo.tabstop = 4 end })
autocmd({ 'BufWinEnter', 'FileType' }, { callback = function()
  if vim.bo.buftype == '' then vim.wo.wrap = vim.bo.filetype == 'markdown' end
end })
autocmd('FileType', { pattern = 'vim', callback = function() vim.wo.foldmethod = 'marker'; vim.wo.foldlevel = 0 end })
autocmd('FileType', { pattern = 'fish', callback = function() vim.cmd.compiler('fish'); vim.bo.textwidth = 79 end })
autocmd('FileType', {
  callback = function(event)
    if vim.bo[event.buf].buftype == '' then
      -- Filetypes without an installed parser retain ordinary syntax highlighting.
      pcall(vim.treesitter.start, event.buf)
    end
  end,
})
if vim.v.vim_did_enter == 0 then
  autocmd('VimEnter', {
    once = true, nested = true,
    callback = function()
      -- Preserve the 14-line shell split, without spawning a shell for scripts,
      -- piped input, commit messages, or restored sessions.
      if #vim.api.nvim_list_uis() == 0 or vim.v.this_session ~= '' or vim.bo.buftype ~= '' then return end
      if vim.tbl_contains({ 'gitcommit', 'gitrebase' }, vim.bo.filetype) then return end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == 'terminal' then return end
      end
      if vim.fn.argc() == 1 and vim.fn.argv(0) == '-' then return end
      require('config.terminal').new('bottom', false)
    end,
  })
end
