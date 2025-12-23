local git_cache = require('libs.git_branch_cache')

local M = {}
M.config = {
  filename_width = nil,
  icons = { branch = '' },
  -- required: user must provide git resolver when calling setup via git_cache_setup
  git_cache_setup = nil, -- optional: table passed to git_cache.setup
  -- Like: { lua = true, markdown = true }
  hide_filename_by_ft = {},
}

local function pad(s, w)
  s = tostring(s)
  return #s > w and s:sub(1, w) or s .. string.rep(' ', w - #s)
end

local function filetype()
  return vim.bo.filetype ~= '' and vim.bo.filetype or 'plaintext'
end

local function filename(max_w)
  if M.config.hide_filename_by_ft[filetype()] then return '' end
  local name = vim.fn.expand('%')
  if name == '' then return '[No Name]' end
  name = name:gsub('\\', '/')
  if max_w and #name > max_w then
    return name:sub(1, max_w - 1) .. '...'
  end
  return name
end

local function screen_percent()
  local cur, tot = vim.fn.line('.'), vim.fn.line('$')
  if cur == 1 then return pad('Top', 3) end
  if cur == tot then return pad('Bot', 3) end
  local p = math.floor(cur / math.max(1, tot) * 100)
  return pad(tostring(p) .. '%', 3)
end

local function cursor_position()
  local cur = vim.api.nvim_win_get_cursor(0)
  local l, c = cur[1], cur[2]
  return pad(string.format('%d:%d', l, c + 1), 7)
end

-- Public API used by statusline expansion
_G.my_statusline = _G.my_statusline or {}
_G.my_statusline.gitbranch = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local br = git_cache.get_branch(bufnr)
  if not br or br == '' then return '' end
  local icon = (M.config.icons and M.config.icons.branch) or 'BR'
  return icon .. ' ' .. br .. ' | '
end
_G.my_statusline.filename = function()
  local fn = filename(M.config.filename_width)
  if fn and fn ~= '' then return fn .. ' ' end
  return ''
end
_G.my_statusline.filetype = filetype
_G.my_statusline.screen = screen_percent
_G.my_statusline.cursor = cursor_position

local function apply()
  local left = ' %{v:lua.my_statusline.gitbranch()}%{v:lua.my_statusline.filename()}%m'
  local right =
  ' %=%{v:lua.my_statusline.filetype()} | %{v:lua.my_statusline.screen()} | %{v:lua.my_statusline.cursor()}'
  vim.o.statusline = left .. right
end
M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  -- initialize git cache if user provided resolver via git_cache_setup or directly via M.config
  local git_opts = M.config.git_cache_setup or {}
  if git_opts.get_git_root == nil and type(M.config.get_git_root) == 'function' then
    git_opts.get_git_root = M.config.get_git_root
  end
  if type(git_opts.get_git_root) == 'function' then
    git_cache.setup(git_opts)
  end
  apply()
end

return M
