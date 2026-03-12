local M = {}

M.config = {
  filename_width = nil,
  icons = { branch = '' },
  hide_filename_by_ft = {},
}

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

-- ========================================================
-- 🚀 原生异步 Git 分支获取器 (零卡顿 / 兼容 Worktree)
-- ========================================================
local function update_git_branch(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  -- 防御：不处理终端、悬浮窗等非正常文件
  if vim.bo[bufnr].buftype ~= '' then return end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' then return end

  local dir = vim.fn.fnamemodify(filepath, ':h')

  -- 使用 Neovim 底层 vim.system 发起异步请求，完全不卡主线程
  vim.system({ 'git', '-C', dir, 'branch', '--show-current' }, { text = true }, function(obj)
    if obj.code == 0 and obj.stdout and obj.stdout ~= '' then
      local branch = vim.trim(obj.stdout)
      -- 回调到主线程更新变量并重绘状态栏
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.b[bufnr].my_git_branch = branch
          vim.cmd('redrawstatus')
        end
      end)
    else
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.b[bufnr].my_git_branch = ''
        end
      end)
    end
  end)
end

-- 只在切换 Buffer、保存文件、或窗口重新获得焦点时才去取 Git 分支
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FocusGained' }, {
  group = vim.api.nvim_create_augroup('MyStatuslineGit', { clear = true }),
  callback = function(args)
    update_git_branch(args.buf)
  end,
})
-- ========================================================

-- Public API used by statusline expansion
_G.my_statusline = _G.my_statusline or {}

_G.my_statusline.gitbranch = function()
  -- 渲染时直接读取缓存变量，0 计算量，0 GC 垃圾！
  local branch = vim.b.my_git_branch
  if not branch or branch == '' then return '' end

  local icon = (M.config.icons and M.config.icons.branch) or ''
  return icon .. ' ' .. branch .. ' | '
end

_G.my_statusline.filename = function()
  local fn = filename(M.config.filename_width)
  if fn and fn ~= '' then return fn .. ' ' end
  return ''
end

_G.my_statusline.filetype = filetype

local function apply()
  local left = ' %{v:lua.my_statusline.gitbranch()}%{v:lua.my_statusline.filename()}%m'
  -- 性能优化：直接使用 Neovim 原生的 C 引擎渲染行号和百分比
  local right = ' %=%{v:lua.my_statusline.filetype()} | %3p%% | %l:%c '

  vim.o.statusline = left .. right
end

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  apply()
end

return M
