local M = {}

-- Cover the top row of editor splits beside the tree. A lower row is a
-- separate workspace region; terminals and other sidebars stay uncovered.
function M.bounds(tree)
  if not tree or not vim.api.nvim_win_is_valid(tree) then return end
  local tree_pos = vim.api.nvim_win_get_position(tree)
  local tree_right = tree_pos[2] + vim.api.nvim_win_get_width(tree)
  local editors = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(tree))) do
    local buf = vim.api.nvim_win_get_buf(win)
    local pos = vim.api.nvim_win_get_position(win)
    if win ~= tree and vim.api.nvim_win_get_config(win).relative == ''
      and vim.bo[buf].buftype == '' and pos[2] > tree_right then
      local info = vim.fn.getwininfo(win)[1]
      editors[#editors + 1] = {
        row = pos[1], col = pos[2], right = pos[2] + info.width,
        bottom = pos[1] + info.height + info.winbar + info.status_height,
      }
    end
  end
  table.sort(editors, function(a, b) return a.row < b.row or (a.row == b.row and a.col < b.col) end)
  local first = editors[1]
  if not first then return end
  local right, bottom = first.right, first.bottom
  for i = 2, #editors do
    local next = editors[i]
    -- Include the separator between adjacent editors, but never span across
    -- an intervening terminal or sidebar.
    if next.row ~= first.row or next.col > right + 1 then break end
    right, bottom = next.right, math.min(bottom, next.bottom)
  end
  if right - first.col < 1 or bottom - first.row < 2 then return end
  return {
    row = first.row - tree_pos[1], col = first.col - tree_pos[2],
    width = right - first.col, height = bottom - first.row,
  }
end

return M
