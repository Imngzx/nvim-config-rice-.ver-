local M = {}

local api = vim.api
local fn = vim.fn
local uv = vim.uv
local fs = vim.fs

local nvim_list_bufs = api.nvim_list_bufs
local nvim_buf_is_loaded = api.nvim_buf_is_loaded
local nvim_buf_get_name = api.nvim_buf_get_name
local nvim_buf_delete = api.nvim_buf_delete
local nvim_create_user_command = api.nvim_create_user_command
local nvim_create_augroup = api.nvim_create_augroup
local nvim_create_autocmd = api.nvim_create_autocmd

local fnameescape = fn.fnameescape
local filereadable = fn.filereadable
local mkdir = fn.mkdir

local fs_stat = uv.fs_stat
local fs_scandir = uv.fs_scandir
local fs_scandir_next = uv.fs_scandir_next
local cwd = uv.cwd

local session_dir = fs.normalize(fn.stdpath('state') .. '/sessions/')
mkdir(session_dir, 'p')

-- 🚀 获取带 Git 分支和项目根目录的标识符
local function get_session_name()
  local ok, snacks_git = pcall(require, 'snacks.git')
  local current_cwd = fs.normalize(cwd() or '')
  local root = (ok and snacks_git.get_root()) or current_cwd

  local branch = ''
  local obj = vim.system({ 'git', '-C', root, 'branch', '--show-current' }):wait()
  if obj.code == 0 and obj.stdout and obj.stdout ~= '' then
    branch = '@@' .. vim.trim(obj.stdout):gsub('[/:]', '%%')
  end

  local name = root:gsub('[/:]', '%%') .. branch
  return session_dir .. name .. '.vim'
end

function M.save()
  if vim.g.session_stopped then return end

  local has_real_file = false
  local bufs = nvim_list_bufs()

  for i = 1, #bufs do
    local buf = bufs[i]
    if nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and nvim_buf_get_name(buf) ~= '' and vim.bo[buf].buftype == '' then
      has_real_file = true
      break
    end
  end

  if not vim.g.session_loaded and not has_real_file then
    return
  end

  vim.o.sessionoptions = 'buffers,curdir,tabpages,winsize,help,skiprtp,folds'
  vim.cmd('silent! cclose')
  vim.cmd('silent! lclose')

  local bpm_ok, bpm = pcall(require, 'bpm')
  local bpm_data = bpm_ok and bpm.to_json() or nil

  local session_name = get_session_name()
  vim.cmd('mksession! ' .. fnameescape(session_name))

  if bpm_data then
    local json_path = session_name:gsub('%.vim$', '.json')
    local fd = io.open(json_path, 'w')
    if fd then
      fd:write(bpm_data)
      fd:close()
    end
  end
end

function M.load(last)
  local target_file = get_session_name()

  if last then
    local max_time = 0
    local latest_file = nil

    local req = fs_scandir(session_dir)
    if req then
      while true do
        local name, type = fs_scandir_next(req)
        if not name then break end

        if type == 'file' and name:match('%.vim$') then
          local path = session_dir .. name
          local stat = fs_stat(path)
          if stat and stat.mtime.sec > max_time then
            max_time = stat.mtime.sec
            latest_file = path
          end
        end
      end
    end

    if latest_file then target_file = latest_file end
  end

  if filereadable(target_file) == 1 then
    -- 清理干扰 Buffer
    local bufs = nvim_list_bufs()
    for i = 1, #bufs do
      local buf = bufs[i]
      local bt = vim.bo[buf].buftype
      local ft = vim.bo[buf].filetype
      if ft == 'snacks_dashboard' or bt == 'nofile' or bt == 'terminal' then
        pcall(nvim_buf_delete, buf, { force = true })
      end
    end

    -- 1. 恢复 Vim 原生 Session
    vim.cmd('silent! source ' .. fnameescape(target_file))

    -- 2. 【BPM 整合】：读取 JSON 恢复 Tab 状态
    local bpm_ok, bpm = pcall(require, 'bpm')
    if bpm_ok then
      local json_path = target_file:gsub('%.vim$', '.json')
      if filereadable(json_path) == 1 then
        local fd = io.open(json_path, 'r')
        if fd then
          local data = fd:read('*a')
          fd:close()
          bpm.from_json(data)
        end
      end
    end

    vim.g.session_loaded = true
    vim.notify('Session & Workspace Restored', vim.log.levels.INFO)
  else
    vim.notify('No Session Found for current branch/dir', vim.log.levels.WARN)
  end
end

function M.setup()
  -- 只在退出时保存
  nvim_create_autocmd('VimLeavePre', {
    group = nvim_create_augroup('DIY_Session', { clear = true }),
    callback = M.save,
  })

  nvim_create_user_command('RestoreSession', function() M.load(false) end, {})
  nvim_create_user_command('RestoreLastSession', function() M.load(true) end, {})
  nvim_create_user_command('StopSession', function()
    vim.g.session_stopped = true
    vim.notify('Session saving disabled for this instance', vim.log.levels.WARN)
  end, {})
end

return M
