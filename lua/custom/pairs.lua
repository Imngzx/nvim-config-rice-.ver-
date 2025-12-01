local M = {}

M.pairs = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`',
}

local function get_char(line, col)
  return line:sub(col, col)
end

function M.open(char)
  return char .. M.pairs[char] .. '<Left>'
end

function M.close(open)
  local close = M.pairs[open]
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col('.')
  if get_char(line, col) == close then
    return '<Right>'
  end
  return close
end

function M.closeopen(char)
  local close = M.pairs[char]
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col('.')
  if get_char(line, col) == close then
    return '<Right>'
  end
  return M.open(char)
end

M.setup = function()
  local opts = { expr = true, noremap = true, replace_keycodes = true }

  -- Asymmetric
  for open, close in pairs({ ['('] = ')', ['['] = ']', ['{'] = '}' }) do
    vim.keymap.set('i', open, function() return M.open(open) end, opts)
    vim.keymap.set('i', close, function() return M.close(open) end, opts)
  end
  -- Symmetric
  for _, sym in ipairs({ '"', "'", '`' }) do
    vim.keymap.set('i', sym, function() return M.closeopen(sym) end, opts)
  end
end

return M
