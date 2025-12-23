local M = {}

-- [LSP]
M.lsp = {
  error = 'E',
  warn = 'W',
  hint = 'H',
  info = 'I',
}

M.basic = {
  dir = '󰉋',
  dir_open = '󰉖',
  file = '󰈔',
  modify = '●',
  close = '󰅖',
  indent = '│'
}

M.git = {
  commit    = '󰜘',
  branch    = '󰘬',
  staged    = 'S',
  added     = 'A',
  deleted   = 'D',
  ignored   = 'I',
  modified  = 'M',
  renamed   = 'R',
  unmerged  = '',
  untracked = 'U',
}

return M
