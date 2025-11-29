local pair_map = { ['('] = ')', ['['] = ']', ['{'] = '}', ['"'] = '"', ["'"] = "'", ['`'] = '`' }

for l, r in pairs(pair_map) do
  vim.keymap.set('i', l, l .. r .. '<Left>', { noremap = true })
  vim.keymap.set('i', r, 'v:lua.MaybeSkip("' .. r .. '")', { expr = true, noremap = true })
end

_G.MaybeSkip = function(ch)
  local col = vim.fn.col('.') - 1
  local line = vim.fn.getline('.')
  if line:sub(col + 1, col + 1) == ch then
    return '<Right>'
  end
  return ch
end
