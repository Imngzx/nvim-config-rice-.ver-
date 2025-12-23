local function pad(s, w)
  s = tostring(s)
  return #s > w and s:sub(1, w) or s .. string.rep(' ', w - #s)
end

-- Elements
local function filename()
  local name = vim.fn.expand('%')
  if name == '' then
    return '[No Name]'
  end
  return name:gsub('\\', '/')
end

local function cursor_position()
  local cur = vim.api.nvim_win_get_cursor(0)
  local l, c = cur[1], cur[2]
  return pad(string.format("%d:%d", l, c + 1), 7)
end

local function screen_percent()
  local cur, tot = vim.fn.line('.'), vim.fn.line('$')
  if cur == 1 then return pad('Top', 3) end
  if cur == tot then return pad('Bot', 3) end
  local p = math.floor(cur / math.max(1, tot) * 100)
  return pad(tostring(p) .. '%', 3)
end

local function filetype() return vim.bo.filetype ~= '' and vim.bo.filetype or 'plain' end

local function fileformat()
  local f = vim.bo.fileformat
  if f == 'unix' then return 'LF' elseif f == 'dos' then return 'CRLF' else return (f and f:upper()) or '' end
end
local function toggle_fileformat(minwid, clicks, button, mods)
  local ff = vim.bo.fileformat
  if ff == 'unix' then
    vim.bo.fileformat = 'dos'
  else
    vim.bo.fileformat = 'unix'
  end
  vim.cmd('redrawstatus')
end

_G.statusline = _G.statusline or {}
_G.statusline.filename = filename
_G.statusline.cursor = cursor_position
_G.statusline.screen = screen_percent
_G.statusline.filetype = filetype
_G.statusline.fileformat = fileformat

-- Display
local left = '%{v:lua.statusline.filename()} %m'
local right =
' %=%{v:lua.statusline.fileformat()} | %{v:lua.statusline.filetype()} | %{v:lua.statusline.screen()} | %{v:lua.statusline.cursor()}'

vim.o.statusline = left .. right
