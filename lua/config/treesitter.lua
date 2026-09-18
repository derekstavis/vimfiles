local M = {}

function M.install()
  return require('nvim-treesitter').install({
    'typescript', 'tsx', 'javascript', 'python', 'haskell', 'lua', 'rust',
    'markdown', 'markdown_inline', 'json', 'yaml', 'go', 'html', 'css',
  })
end

function M.update()
  local ts = require('nvim-treesitter')
  local available = {}
  for _, name in ipairs(ts.get_available()) do available[name] = true end
  -- Custom parsers (such as the existing UVML parser) are managed separately.
  local installed = vim.tbl_filter(function(name) return available[name] end, ts.get_installed())
  return ts.update(installed)
end

return M
