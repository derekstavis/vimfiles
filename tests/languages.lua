-- Requires :InstallTools and :InstallParsers.
local function run()
  local temp = vim.fn.tempname()
  vim.fn.mkdir(temp, 'p')
  vim.fn.writefile({ '{"compilerOptions":{"strict":true}}' }, temp .. '/tsconfig.json')
  local path = temp .. '/example.ts'
  vim.fn.writefile({ 'const value:number="wrong"', 'console.log(value)' }, path)
  vim.cmd.edit(path)
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.wait(30000, function()
    return #vim.lsp.get_clients({ bufnr = buf, name = 'ts_ls' }) == 1
  end, 50), 'TypeScript LSP did not attach')
  local client = vim.lsp.get_clients({ bufnr = buf, name = 'ts_ls' })[1]
  assert(vim.wait(30000, function() return #vim.diagnostic.get(buf) > 0 end, 50), 'Expected a real type diagnostic')
  assert(vim.diagnostic.get(buf)[1].severity == vim.diagnostic.severity.ERROR)
  local definition = client:request_sync('textDocument/definition', {
    textDocument = { uri = vim.uri_from_bufnr(buf) }, position = { line = 1, character = 13 },
  }, 10000, buf)
  assert(definition and definition.result and #definition.result > 0, 'Definition request failed')
  local rename = client:request_sync('textDocument/rename', {
    textDocument = { uri = vim.uri_from_bufnr(buf) }, position = { line = 1, character = 13 }, newName = 'renamed',
  }, 10000, buf)
  assert(rename and rename.result, 'Rename request failed')
  vim.lsp.util.apply_workspace_edit(rename.result, client.offset_encoding)
  assert(vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]:find('renamed'), 'Rename must edit the reference')
  vim.cmd.write()
  local formatted = vim.fn.readfile(path)
  assert(formatted[1] == 'const renamed: number = "wrong";', 'Prettier format-on-save did not run')

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    'const result = await evaluate<number>(`print("hello")`);',
    'evaluate("print(42)");',
  })
  local parser = vim.treesitter.get_parser(buf, 'typescript')
  parser:parse(true)
  assert(parser:children().python, 'Python injection inside evaluate() was lost')
  assert(#parser:children().python:trees() == 2, 'Both template and regular strings must inject Python')
  assert(#vim.treesitter.query.get_files('typescript', 'injections') > 1, 'Custom injections must extend upstream queries')
  client:stop(true)
  vim.fn.delete(temp, 'rf')
  print('PASS: native LSP attachment, diagnostics, definitions, rename, format-on-save, Python injections')
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd.cquit({ args = { '1' } })
else
  vim.cmd('qa!')
end
