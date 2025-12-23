local M = {}

-- config populated via setup
M.config = {
  -- required: function(bufnr_or_path) -> path (repo root or .git path) or nil
  get_git_root = nil,
  watch_poll_interval = 1000, -- ms, used if fs_event unavailable
}

local sep = package.config:sub(1, 1)
local uv = vim.loop

-- runtime caches
local branch_cache = {}  -- maps bufnr -> branch_name (string or '')
branch_cache._meta = {}  -- maps bufnr -> gitdir (normalized .git path)
local head_watchers = {} -- maps gitdir -> watcher

local function safe_read_first_line(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local ok, line = pcall(function() return f:read('*l') end)
  f:close()
  if not ok then return nil end
  return line
end

local function normalize_gitdir(candidate)
  if not candidate or candidate == '' then return nil end
  -- if candidate ends with .git, use it
  if candidate:sub(-4) == '.git' then
    if uv.fs_stat(candidate) then return candidate end
    return nil
  end
  -- if it's a directory, check candidate/.git
  local stat = uv.fs_stat(candidate)
  if stat and stat.type == 'directory' then
    local dotgit = candidate .. sep .. '.git'
    if uv.fs_stat(dotgit) then return dotgit end
  end
  -- if it's a file path (or something else), try parent dirs for .git
  local try = candidate
  while try and try ~= '' do
    local dotgit = try .. sep .. '.git'
    if uv.fs_stat(dotgit) then return dotgit end
    local parent = try:match('(.*)' .. sep .. '.-')
    if not parent or parent == try then break end
    try = parent
  end
  return nil
end

local function read_head_from_gitdir(gitdir)
  if not gitdir or gitdir == '' then return nil end
  local head_path = gitdir .. sep .. 'HEAD'
  local head = safe_read_first_line(head_path)
  if not head then return nil end
  local branch = head:match('ref: refs/heads/(.+)$')
  if branch then return branch end
  return head:sub(1, 6)
end

local function stop_watcher_for_gitdir(gitdir)
  local w = head_watchers[gitdir]
  if not w then return end
  pcall(function()
    if w.stop then w:stop() end
    if w.close then w:close() end
  end)
  head_watchers[gitdir] = nil
end

local function watch_head(gitdir)
  if not gitdir or gitdir == '' then return end
  if head_watchers[gitdir] then return end

  local head_path = gitdir .. sep .. 'HEAD'
  local watcher = nil

  if uv and uv.new_fs_event then
    local ok, w = pcall(uv.new_fs_event)
    if ok and w then
      watcher = w
      watcher:start(head_path, {}, vim.schedule_wrap(function()
        -- refresh all bufnrs that map to this gitdir
        for bufnr, gitr in pairs(branch_cache._meta or {}) do
          if gitr == gitdir then
            branch_cache[bufnr] = read_head_from_gitdir(gitdir) or ''
          end
        end
      end))
    end
  end

  if not watcher and uv and uv.new_fs_poll then
    local ok, wp = pcall(uv.new_fs_poll)
    if ok and wp then
      watcher = wp
      watcher:start(head_path, M.config.watch_poll_interval or 1000, vim.schedule_wrap(function()
        for bufnr, gitr in pairs(branch_cache._meta or {}) do
          if gitr == gitdir then
            branch_cache[bufnr] = read_head_from_gitdir(gitdir) or ''
          end
        end
      end))
    end
  end

  if watcher then head_watchers[gitdir] = watcher end
end

-- remove cache for a bufnr and cleanup watchers if unused
local function clear_buf_cache(bufnr)
  local gitdir = branch_cache._meta[bufnr]
  branch_cache[bufnr] = nil
  branch_cache._meta[bufnr] = nil
  -- check if any other bufnr uses this gitdir
  if gitdir then
    for b, g in pairs(branch_cache._meta) do
      if g == gitdir then return end
    end
    -- none uses it -> stop watcher
    stop_watcher_for_gitdir(gitdir)
  end
end

-- Public: refresh cache for a specific bufnr (synchronous) and start watcher
function M.refresh_for_buf(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  -- resolve git root via user function
  local git_root = nil
  if type(M.config.get_git_root) == 'function' then
    local ok, res = pcall(M.config.get_git_root, bufnr)
    if ok and res and res ~= '' then git_root = res end
  end

  local gitdir = normalize_gitdir(git_root)
  if not gitdir then
    clear_buf_cache(bufnr)
    return ''
  end

  local branch = read_head_from_gitdir(gitdir) or ''
  branch_cache[bufnr] = branch
  branch_cache._meta[bufnr] = gitdir
  watch_head(gitdir)
  return branch
end

-- Public: get branch for bufnr (fast)
function M.get_branch(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if branch_cache[bufnr] == nil then
    M.refresh_for_buf(bufnr)
  end
  return branch_cache[bufnr] or ''
end

-- Setup: user provides get_git_root and optional poll interval
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend('force', M.config, opts)
  if type(M.config.get_git_root) ~= 'function' then
    error('git_root_cache.setup requires get_git_root = function(bufnr_or_path) -> path')
  end

  -- autocmds to refresh/clear caches
  vim.api.nvim_create_augroup('MyStatuslineGitRootCache', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'DirChanged' }, {
    group = 'MyStatuslineGitRootCache',
    callback = function(ev)
      local bufnr = ev.buf or vim.api.nvim_get_current_buf()
      M.refresh_for_buf(bufnr)
    end,
  })
  -- clear cache on buffer delete
  vim.api.nvim_create_autocmd('BufDelete', {
    group = 'MyStatuslineGitRootCache',
    callback = function(ev)
      local bufnr = ev.buf
      if bufnr then clear_buf_cache(bufnr) end
    end,
  })

  -- prime current buffer
  M.refresh_for_buf(vim.api.nvim_get_current_buf())
end

return M
