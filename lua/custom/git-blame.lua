local M = {}

local api = vim.api
local uv = vim.uv
local nvim_buf_is_valid = api.nvim_buf_is_valid
local nvim_buf_del_extmark = api.nvim_buf_del_extmark
local fn_mode = vim.fn.mode
local nvim_get_current_buf = api.nvim_get_current_buf
local nvim_buf_get_changedtick = api.nvim_buf_get_changedtick
local nvim_win_get_cursor = api.nvim_win_get_cursor
local nvim_buf_set_extmark = api.nvim_buf_set_extmark
local nvim_buf_get_name = api.nvim_buf_get_name
local nvim_buf_get_lines = api.nvim_buf_get_lines
local nvim_create_namespace = api.nvim_create_namespace
local nvim_create_augroup = api.nvim_create_augroup
local nvim_create_autocmd = api.nvim_create_autocmd
local nvim_list_wins = api.nvim_list_wins
local nvim_win_get_buf = api.nvim_win_get_buf

local NS = nvim_create_namespace('DIYGitBlame')
local EXT_ID = 1

local b_state = {}
local fetch_timers = {}
local current_author = nil

local config = {
  enabled = true,
  message_template = '  󰊢 <sha> •  <author> •  <date> • 󰈔 <summary>',
  message_when_not_committed = '  󰊢 Not Committed Yet',
  date_format = '%r',
  highlight_group = 'Comment',
  ignored_filetypes = {},
  delay = 250,
  max_summary_length = 50,
  get_git_root = function(filepath)
    return vim.fs.root(filepath, '.git')
  end,
}

local function escape_gsub(s) return (s:gsub('%%', '%%%%')) end

local function truncate(str, max)
  return (max and max > 0 and #str > max) and (str:sub(1, max) .. '...') or str
end

local function time_ago(time)
  local diff = math.max(0, os.time() - time)
  if diff < 60 then return 'just now' end
  local mins = math.floor(diff / 60)
  if mins < 60 then return mins .. (mins == 1 and ' min ago' or ' mins ago') end
  local hours = math.floor(mins / 60)
  if hours < 24 then return hours .. (hours == 1 and ' hr ago' or ' hrs ago') end
  local days = math.floor(hours / 24)
  if days < 30 then return days .. (days == 1 and ' day ago' or ' days ago') end
  local months = math.floor(days / 30)
  if months < 12 then return months .. (months == 1 and ' mo ago' or ' mos ago') end
  local years = math.floor(days / 365.25)
  return years .. (years == 1 and ' yr ago' or ' yrs ago')
end

local function parse_porcelain(stdout)
  local blames, commit_cache = {}, {}
  local c_sha, c_final, c_size = nil, nil, nil

  for line in stdout:gmatch('([^\n]+)') do
    local sha, _, final_line, group_size = line:match('^([0-9a-fA-F]+)%s+(%d+)%s+(%d+)%s+(%d+)')
    if sha then
      c_sha, c_final, c_size = sha, tonumber(final_line), tonumber(group_size)
      if not commit_cache[sha] then commit_cache[sha] = { sha = sha } end
      local commit = commit_cache[sha]
      for i = 0, c_size - 1 do blames[c_final + i] = commit end
    elseif c_sha and line:sub(1, 1) ~= '\t' then
      local key, val = line:match('^(%S+)%s+(.*)')
      if key and val then
        local commit = commit_cache[c_sha]
        if key == 'author' then
          commit.author = val
        elseif key == 'author-time' then
          commit.date = tonumber(val)
        elseif key == 'committer' then
          commit.committer = val
        elseif key == 'committer-time' then
          commit.committer_date = tonumber(val)
        elseif key == 'summary' then
          commit.summary = val
        end
      end
    end
  end
  return blames
end

local function format_blame(commit)
  if not commit then return nil end
  if commit.sha and commit.sha:match('^0+$') then return config.message_when_not_committed end

  local author = commit.author or 'Unknown'
  if current_author and author == current_author then author = 'You' end

  local date_str = ''
  if commit.date then
    if config.date_format == '%r' then
      date_str = time_ago(commit.date)
    else
      date_str = os.date(config.date_format, commit.date) --[[@as string]]
    end
  end

  local summary = truncate(commit.summary or '', config.max_summary_length)
  local sha = commit.sha and commit.sha:sub(1, 7) or ''

  local text = config.message_template
  text = text:gsub('<author>', escape_gsub(author))
  text = text:gsub('<date>', escape_gsub(date_str))
  text = text:gsub('<summary>', escape_gsub(summary))
  text = text:gsub('<sha>', escape_gsub(sha))

  return text
end

local function clear_blame(bufnr)
  if nvim_buf_is_valid(bufnr) then
    nvim_buf_del_extmark(bufnr, NS, EXT_ID)
  end
end

local function is_insert_mode()
  return fn_mode():sub(1, 1) == 'i'
end

local function show_blame(bufnr)
  if not config.enabled or nvim_get_current_buf() ~= bufnr or is_insert_mode() then return end

  local st = b_state[bufnr]
  if not st or not st.blames or st.tick ~= nvim_buf_get_changedtick(bufnr) then
    clear_blame(bufnr)
    return
  end

  local line = nvim_win_get_cursor(0)[1]
  local text = format_blame(st.blames[line])
  if not text then return clear_blame(bufnr) end

  nvim_buf_set_extmark(bufnr, NS, line - 1, 0, {
    id = EXT_ID,
    virt_text = { { text, config.highlight_group } },
    virt_text_pos = 'eol',
    hl_mode = 'combine',
    priority = 1000,
  })
end

local function fetch_blame(bufnr)
  if not nvim_buf_is_valid(bufnr) then return end

  local filepath = nvim_buf_get_name(bufnr)
  if filepath == '' or filepath:match('^[%w%+%.%-]+://') then return end
  if vim.tbl_contains(config.ignored_filetypes, vim.bo[bufnr].filetype) then return end

  local root = config.get_git_root(filepath)
  if not root then return end

  local stats = uv.fs_stat(filepath)
  if stats and stats.size > 1.5 * 1024 * 1024 then return end

  local tick = nvim_buf_get_changedtick(bufnr)

  local ok, lines = pcall(nvim_buf_get_lines, bufnr, 0, -1, false)
  if not ok or type(lines) ~= 'table' or #lines == 0 then return end

  local stdin = table.concat(lines, '\n') .. '\n'
  local cmd = { 'git', '--no-pager', '-C', root, 'blame', '-b', '-p', '-w', '--date', 'unix',
    '--contents', '-', filepath }

  local st = b_state[bufnr] or {}
  b_state[bufnr] = st
  if st.job then st.job:kill('sigterm') end

  st.job = vim.system(cmd, { stdin = stdin, text = true }, function(obj)
    vim.schedule(function()
      if not nvim_buf_is_valid(bufnr) then return end
      st.job = nil
      if obj.code == 0 and obj.stdout then
        st.blames = parse_porcelain(obj.stdout)
        st.tick = tick
        if nvim_get_current_buf() == bufnr and not is_insert_mode() then show_blame(bufnr) end
      end
    end)
  end)
end

local function queue_fetch(bufnr)
  if not config.enabled or not nvim_buf_is_valid(bufnr) then return end
  if fetch_timers[bufnr] then fetch_timers[bufnr]:stop() else fetch_timers[bufnr] = uv.new_timer() end
  fetch_timers[bufnr]:start(config.delay, 0, vim.schedule_wrap(function() fetch_blame(bufnr) end))
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
  local aug = nvim_create_augroup('DIYGitBlame', { clear = true })

  nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'BufWritePost', 'InsertLeave' }, {
    group = aug, callback = function(args) if not is_insert_mode() then queue_fetch(args.buf) end end
  })
  nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = aug,
    callback = function(args)
      clear_blame(args.buf)
      if not is_insert_mode() then queue_fetch(args.buf) end
    end
  })
  local last_state = { buf = -1, row = -1 }
  nvim_create_autocmd('CursorMoved', {
    group = aug,
    callback = function(args)
      local cur_row = nvim_win_get_cursor(0)[1]
      local cur_buf = args.buf

      if cur_row == last_state.row and cur_buf == last_state.buf then return end

      last_state.row = cur_row
      last_state.buf = cur_buf
      show_blame(args.buf)
    end
  })
  nvim_create_autocmd('InsertEnter', {
    group = aug, callback = function(args) clear_blame(args.buf) end
  })
  nvim_create_autocmd('BufWipeout', {
    group = aug,
    callback = function(args)
      local b = args.buf
      fetch_timers[b] = require('snacks').util.stop(fetch_timers[b])
      if b_state[b] then
        if b_state[b].job then b_state[b].job:kill('sigterm') end
        b_state[b] = nil
      end
    end
  })

  if config.enabled then
    if not current_author then
      vim.system({ 'git', 'config', 'user.name' }, { text = true }, function(obj)
        if obj.code == 0 and obj.stdout then current_author = vim.trim(obj.stdout) end
      end)
    end
    local wins = nvim_list_wins()
    for i = 1, #wins do
      queue_fetch(nvim_win_get_buf(wins[i]))
    end
  end
end

function M.toggle()
  config.enabled = not config.enabled
  if config.enabled then
    local wins = nvim_list_wins()
    for i = 1, #wins do
      queue_fetch(nvim_win_get_buf(wins[i]))
    end
  else
    for buf, _ in pairs(b_state) do clear_blame(buf) end
  end
end

return M
