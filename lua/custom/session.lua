local M = {}

local fn = vim.fn
local uv = vim.uv
local api = vim.api

local session_dir = fn.stdpath('state') .. '/sessions/'

if fn.isdirectory(session_dir) == 0 then
  fn.mkdir(session_dir, 'p')
end

local function get_session_file()
  local dir = fn.getcwd():gsub('[\\/:]', '%%')
  return session_dir .. dir .. '.vim'
end

-- 【核心 1：安心退出，防呆保护】
function M.save()
  -- 如果被显式禁用，跳过
  if vim.g.session_stopped then return end

  -- 🛡️ 智能检测：判断当前是否有“值得保存”的工作？
  local has_real_file = false
  for _, buf in ipairs(api.nvim_list_bufs()) do
    -- 如果有任何一个列出的、已加载的、且名字不为空的 Buffer，说明你在干活
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and api.nvim_buf_get_name(buf) ~= '' then
      has_real_file = true
      break
    end
  end

  -- 🛡️ 如果你一没有加载过历史 Session，二没有打开任何实质性文件（比如只在看 Dashboard）
  -- 那就直接 return，保护上一次的 Session 不被“空状态”覆盖。放心大胆地 :q 吧！
  if not vim.g.session_loaded and not has_real_file then
    return
  end

  -- 设定保存的内容：去掉无用项，确保纯净
  vim.o.sessionoptions = 'buffers,curdir,tabpages,winsize,help,globals,skiprtp'
  vim.cmd('mksession! ' .. fn.fnameescape(get_session_file()))
end

-- 【核心 2：精准恢复，光标归位】
function M.load(last)
  local target_file = get_session_file()

  if last then
    local max_time = 0
    local latest_file = nil
    local fd = uv.fs_opendir(session_dir, nil, 100)
    if fd then
      local entries = uv.fs_readdir(fd)
      uv.fs_closedir(fd)
      if entries then
        for _, entry in ipairs(entries) do
          if entry.name:match('%.vim$') then
            local path = session_dir .. entry.name
            local stat = uv.fs_stat(path)
            if stat and stat.mtime.sec > max_time then
              max_time = stat.mtime.sec
              latest_file = path
            end
          end
        end
      end
    end
    if latest_file then target_file = latest_file end
  end

  if fn.filereadable(target_file) == 1 then
    -- 🧹 恢复前的极限操作：把现在的 Dashboard 或欢迎页面彻底扬了
    -- 防止它们干扰 Session 的分屏比例，导致光标位置错乱
    for _, buf in ipairs(api.nvim_list_bufs()) do
      if vim.bo[buf].filetype == 'snacks_dashboard' or vim.bo[buf].buftype == 'nofile' then
        api.nvim_buf_delete(buf, { force = true })
      end
    end

    -- 执行恢复
    vim.cmd('silent! source ' .. fn.fnameescape(target_file))

    -- 打上标记：证明这个实例是从 Session 唤醒的，后续 :q 会无条件保存
    vim.g.session_loaded = true
    vim.notify('󰦒 Session & Cursor Restored', vim.log.levels.INFO)
  else
    vim.notify('No Session Found', vim.log.levels.WARN)
  end
end

function M.setup()
  -- 绑定到 Neovim 的终极退出前夕事件
  api.nvim_create_autocmd('VimLeavePre', {
    group = api.nvim_create_augroup('DIY_Session', { clear = true }),
    callback = M.save,
  })

  api.nvim_create_user_command('RestoreSession', function() M.load(false) end, {})
  api.nvim_create_user_command('RestoreLastSession', function() M.load(true) end, {})
  api.nvim_create_user_command('StopSession', function()
    vim.g.session_stopped = true
    vim.notify('Session saving disabled for this instance', vim.log.levels.WARN)
  end, {})
end

return M
