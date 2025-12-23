local M = {}

M.get_icon_by_ext = function(ext) return M.ext[ext] end

M.get_icon_by_ft = function(ft) return M.ft[ft] end

M.get_icon_by_name = function(name)
  -- File
  if M.file[name] then return M.file[name] end
  local lower = name:lower()
  for k, v in pairs(M.file) do
    if k:lower() == lower then return v end
  end

  -- Filetype
  -- Prefer more ext (example: .tar.gz -> "tar.gz" then "gz")
  local parts = {}
  for part in name:gmatch('[^%.]+') do
    table.insert(parts, part)
  end
  if #parts > 1 then
    for i = 2, #parts do
      local ext = table.concat(parts, '.', i)
      if M.ext[ext] then return M.ext[ext] end
      if M.ft[ext] then return M.ft[ext] end
    end
  end

  -- Ext
  local ext = name:match('%.([^.]+)$')
  return M.get_icon_by_ext(ext)
end

-- [LSP]
M.lsp = {
  error = 'E',
  warn = 'W',
  hint = 'H',
  info = 'I',
}

M.basic = {
  -- directory = '',
  file = '',
  modify = '●',
  close = '󰅖',
}

return M
