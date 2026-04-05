local M = {}

local session_dir = vim.fs.normalize(vim.fn.stdpath('state') .. '/sessions/')
vim.fn.mkdir(session_dir, 'p')

-- 🚀 核心升级：获取带 Git 分支和项目根目录的标识符
local function get_session_name()
  -- 1. 尝试获取项目根目录（优先使用 Snacks 的能力），找不到再用 cwd
  local ok, snacks_git = pcall(require, 'snacks.git')
  local cwd = vim.fs.normalize(vim.uv.cwd() or '')
  local root = (ok and snacks_git.get_root()) or cwd

  -- 2. 获取当前 Git 分支名（同步执行，因为只有在退出和手动加载时才调用，不卡正常编辑）
  local branch = ''
  local obj = vim.system({ 'git', '-C', root, 'branch', '--show-current' }):wait()
  if obj.code == 0 and obj.stdout and obj.stdout ~= '' then
    branch = '@@' .. vim.trim(obj.stdout)
  end

  -- 3. 组合文件名：路径名替换掉特殊字符 + Git 分支名
  local name = root:gsub('[/:]', '%%') .. branch
  return session_dir .. name .. '.vim'
end

function M.save()
  if vim.g.session_stopped then return end

  -- 避免保存全是无效 Buffer 的空 Session
  local has_real_file = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= '' and vim.bo[buf].buftype == '' then
      has_real_file = true
      break
    end
  end

  if not vim.g.session_loaded and not has_real_file then
    return
  end

  vim.o.sessionoptions = 'buffers,curdir,tabpages,winsize,help,skiprtp,folds'
  -- 确保保存前关闭所有的悬浮窗、通知等，防止下次打开时报错
  vim.cmd('silent! cclose')
  vim.cmd('silent! lclose')

  vim.cmd('mksession! ' .. vim.fn.fnameescape(get_session_name()))
end

function M.load(last)
  local target_file = get_session_name()

  if last then
    local max_time = 0
    local latest_file = nil

    for name, type in vim.fs.dir(session_dir) do
      if type == 'file' and name:match('%.vim$') then
        local path = session_dir .. name
        local stat = vim.uv.fs_stat(path)
        if stat and stat.mtime.sec > max_time then
          max_time = stat.mtime.sec
          latest_file = path
        end
      end
    end

    if latest_file then target_file = latest_file end
  end

  if vim.fn.filereadable(target_file) == 1 then
    -- 清理干扰 Buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local bt = vim.bo[buf].buftype
      if vim.bo[buf].filetype == 'snacks_dashboard' or bt == 'nofile' or bt == 'terminal' then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end

    vim.cmd('silent! source ' .. vim.fn.fnameescape(target_file))
    vim.g.session_loaded = true
    vim.notify('Session & Cursor Restored', vim.log.levels.INFO)
  else
    vim.notify('No Session Found for current branch/dir', vim.log.levels.WARN)
  end
end

function M.setup()
  -- 只在退出时保存
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('DIY_Session', { clear = true }),
    callback = M.save,
  })

  vim.api.nvim_create_user_command('RestoreSession', function() M.load(false) end, {})
  vim.api.nvim_create_user_command('RestoreLastSession', function() M.load(true) end, {})
  vim.api.nvim_create_user_command('StopSession', function()
    vim.g.session_stopped = true
    vim.notify('Session saving disabled for this instance', vim.log.levels.WARN)
  end, {})
end

return M
