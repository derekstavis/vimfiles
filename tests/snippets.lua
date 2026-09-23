-- Runs in the UI test coroutine, so real Insert/Normal mode events can fire.
local function settle()
  local thread = coroutine.running()
  vim.defer_fn(function()
    local ok, err = coroutine.resume(thread)
    if not ok then error(err) end
  end, 100)
  coroutine.yield()
end
local function input(keys)
  vim.api.nvim_input(keys)
  settle()
end
vim.cmd.enew()
local buf = vim.api.nvim_get_current_buf()
local ns = vim.api.nvim_get_namespaces().MiniSnippetsNodes
local function marks() return vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true }) end
local function check_stopped(text)
  assert(MiniSnippets.session.get() == nil, 'Returning to Normal mode must end all snippet sessions')
  assert(#marks() == 0, 'Snippet underlines and final markers must be removed')
  assert(vim.api.nvim_get_current_line() == text, 'Stopping a snippet must preserve its text')
end

-- Exercise the same insertion backend as accepted LSP function completions.
input('i')
MiniCompletion.default_snippet_insert('sum_overriding_scopes(${1:other})$0')
settle()
input('Grade::level_by(3)')
assert(MiniSnippets.session.get().cur_tabstop == '1', 'Argument must remain active while typing')
assert(#marks() > 0, 'Active snippet must have decorations')
input('<Esc>')
check_stopped('sum_overriding_scopes(Grade::level_by(3))')

-- Field navigation remains available until the user finishes insertion.
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '' })
input('i')
MiniCompletion.default_snippet_insert('call(${1:first}, ${2:second})$0')
settle()
input('<C-l>')
assert(MiniSnippets.session.get().cur_tabstop == '2', 'Ctrl-L must advance to the next argument')
input('<C-h>')
assert(MiniSnippets.session.get().cur_tabstop == '1', 'Ctrl-H must return to the previous argument')

-- Nested function completions must not leave the outer session behind.
MiniCompletion.default_snippet_insert('nested(${1:value})$0')
settle()
assert(#MiniSnippets.session.get(true) == 2, 'Expected nested snippet sessions')
local text = vim.api.nvim_get_current_line()
input('<Esc>')
check_stopped(text)
vim.api.nvim_buf_delete(buf, { force = true })
