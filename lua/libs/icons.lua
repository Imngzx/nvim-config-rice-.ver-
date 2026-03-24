local M = {}

-- [LSP]
M.lsp = {
  error = ' ',
  warn = ' ',
  hint = ' ',
  info = ' ',
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
  commit = '󰜘',
  branch = '󰘬',
  staged = 'S',
  added = '',
  deleted = '',
  ignored = '',
  modified = '',
  renamed = 'R',
  unmerged = '',
  untracked = 'U',
}

return M
