-- Requires the TypeScript language server from :InstallTools.
local function wait_for(timeout, predicate)
  local deadline = vim.uv.hrtime() + timeout * 1e6
  while vim.uv.hrtime() < deadline do
    if predicate() then return true end
    local thread = coroutine.running()
    vim.defer_fn(function() assert(coroutine.resume(thread)) end, 20)
    coroutine.yield()
  end
  return predicate()
end
local function run()
  local temp = vim.fn.tempname()
  vim.fn.mkdir(temp, 'p')
  vim.fn.writefile({ '{"compilerOptions":{"strict":true}}' }, temp .. '/tsconfig.json')
  local dependency, main = temp .. '/dependency.ts', temp .. '/main.ts'
  vim.fn.writefile({ 'export const value = "wrong";' }, dependency)
  vim.fn.writefile({ 'import { value } from "./dependency";', 'const result: number = value;' }, main)
  vim.cmd.edit(dependency)
  local dep_buf = vim.api.nvim_get_current_buf()
  assert(wait_for(15000, function()
    return #vim.lsp.get_clients({ bufnr = dep_buf, name = 'ts_ls' }) == 1
  end), 'TypeScript server did not attach to the dependency')
  vim.cmd.edit(main)
  local buf = vim.api.nvim_get_current_buf()
  local function errors() return vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR }) end
  assert(wait_for(15000, function() return #errors() > 0 end),
    'Expected a diagnostic from the dependency type')
  local client = assert(vim.lsp.get_clients({ bufnr = buf, name = 'ts_ls' })[1])

  -- Simulate an agent editing a loaded, hidden dependency on disk.
  vim.fn.writefile({ 'export const value = 42;' }, dependency)
  vim.api.nvim_exec_autocmds('CursorHold', { buffer = buf })
  assert(wait_for(3000, function()
    return vim.api.nvim_buf_get_lines(dep_buf, 0, 1, false)[1] == 'export const value = 42;'
  end), 'Idle checks must reload externally changed hidden buffers')
  assert(wait_for(15000, function() return #errors() == 0 end),
    'The existing LSP must clear dependent errors after reloading: ' .. vim.inspect(errors()))
  assert(vim.lsp.get_clients({ bufnr = buf, name = 'ts_ls' })[1].id == client.id,
    'External edits must not require restarting the language server')
  assert(vim.api.nvim_get_current_buf() == buf, 'Reloading dependencies must preserve focus')

  -- An external edit to the visible buffer should also reload on focus.
  vim.fn.writefile({ 'export const updated = true;' }, main)
  vim.api.nvim_exec_autocmds('FocusGained', {})
  assert(wait_for(3000, function() return vim.api.nvim_get_current_line() == 'export const updated = true;' end),
    'Focus checks must reload the visible buffer')

  -- Keep local edits when disk contents conflict. Avoid an interactive prompt
  -- in the test by choosing to retain the buffer via the standard conflict hook.
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'export const local_edit = true;' })
  vim.fn.writefile({ 'export const external_edit = false;' }, main)
  local conflict = false
  local id = vim.api.nvim_create_autocmd('FileChangedShell', {
    buffer = buf, callback = function() conflict = true; vim.v.fcs_choice = '' end,
  })
  vim.api.nvim_exec_autocmds('FocusGained', {})
  assert(wait_for(3000, function() return conflict end), 'Expected conflict detection')
  assert(vim.api.nvim_get_current_line() == 'export const local_edit = true;' and vim.bo.modified,
    'External reloads must preserve unsaved edits')
  vim.api.nvim_del_autocmd(id)
  client:stop(true)
  vim.api.nvim_buf_delete(buf, { force = true })
  vim.api.nvim_buf_delete(dep_buf, { force = true })
  vim.fn.delete(temp, 'rf')
  print('PASS: external edits reload visible/hidden buffers, refresh LSP diagnostics, and preserve local edits')
end
vim.schedule(coroutine.wrap(function()
  local ok, err = xpcall(run, debug.traceback)
  if not ok then io.stderr:write(err .. '\n') end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end))
