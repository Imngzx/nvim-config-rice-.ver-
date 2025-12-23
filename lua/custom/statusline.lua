local M = {}
M.config = {
  -- Required: function(ft) -> icon
  ft_icon = nil,
  filename_width = nil,
}

local function pad(s, w)
  s = tostring(s)
  return #s > w and s:sub(1, w) or s .. string.rep(' ', w - #s)
end

local function filename(max_w)
  local name = vim.fn.expand('%')
  if name == '' then return '[No Name]' end
  name = name:gsub('\\', '/')
  if max_w and #name > max_w then
    return name:sub(1, max_w - 1) .. '…'
  end
  return name
end

local function cursor_position()
  local cur = vim.api.nvim_win_get_cursor(0)
  local l, c = cur[1], cur[2]
  return pad(string.format('%d:%d', l, c + 1), 7)
end

local function screen_percent()
  local cur, tot = vim.fn.line('.'), vim.fn.line('$')
  if cur == 1 then return pad('Top', 3) end
  if cur == tot then return pad('Bot', 3) end
  local p = math.floor(cur / math.max(1, tot) * 100)
  return pad(tostring(p) .. '%', 3)
end

local function filetype(cfg)
  local ft = vim.bo.filetype ~= '' and vim.bo.filetype or 'plaintext'
  return (cfg.ft_icon(ft) or '') .. ' ' .. ft
end

-- Public API used by statusline expansion
_G.my_statusline = _G.my_statusline or {}
_G.my_statusline.filename = function() return filename(M.config.filename_width) end
_G.my_statusline.cursor = cursor_position
_G.my_statusline.screen = screen_percent
_G.my_statusline.filetype = function() return filetype(M.config) end

local function apply()
  local left = '%{v:lua.my_statusline.filename()} %m'
  local right =
  '%=%{v:lua.my_statusline.filetype()} | %{v:lua.my_statusline.screen()} | %{v:lua.my_statusline.cursor()}'
  vim.o.statusline = left .. right
end

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  -- validate ft_icon
  if type(M.config.ft_icon) ~= 'function' then
    error('my_statusline.setup requires ft_icon = function(ft) -> icon')
  end
  apply()
end

return M
