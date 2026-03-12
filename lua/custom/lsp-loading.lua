local M = {}

-- [本地私有变量与配置] (保持不变)
local config = {
  spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  icons = { lsp = '󰒋' },
  highlights = { icon = 'DiagnosticWarn', msg = 'Comment' }
}

local active_tasks = {}
local frame = 1
local timer = nil
local win_id = nil
local buf_id = nil

-- [本地私有函数] (保持不变)
local function cleanup()
  if timer then
    timer:stop()
    if not timer:is_closing() then timer:close() end
    timer = nil
  end
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, true)
    win_id = nil
  end
end

local function get_win_config(lines_count)
  local width = 40
  return {
    relative = 'editor',
    anchor = 'SE',
    row = vim.o.lines - (vim.o.laststatus > 0 and 2 or 1),
    col = vim.o.columns - 1,
    width = width,
    height = lines_count > 0 and lines_count or 1,
    style = 'minimal',
    focusable = false,
    noautocmd = true,
    zindex = 50,
  }
end

local function update_window()
  -- 👇【新增核心修复：每次刷新动画前，检测 LSP 进程是不是已经死了，死了就强行清理】
  for client_id, _ in pairs(active_tasks) do
    if not vim.lsp.get_client_by_id(client_id) then
      active_tasks[client_id] = nil
    end
  end
  -- 👆 新增结束

  if vim.tbl_isempty(active_tasks) then
    cleanup()
    return
  end

  local lines = {}
  local sorted_clients = vim.tbl_keys(active_tasks)
  table.sort(sorted_clients)

  for _, client_id in ipairs(sorted_clients) do
    local task = active_tasks[client_id]
    local spinner_icon = config.spinner[frame]
    local percentage = task.percentage and string.format(' %d%%', task.percentage) or ''
    local line = string.format(' %s %s %s: %s%s ',
      config.icons.lsp, spinner_icon, task.title, task.message or 'Loading', percentage)
    table.insert(lines, line)
  end

  if #lines == 0 then
    cleanup()
    return
  end

  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    buf_id = vim.api.nvim_create_buf(false, true)
  end
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace('diy_fidget')
  vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
  for i = 0, #lines - 1 do
    vim.api.nvim_buf_add_highlight(buf_id, ns, config.highlights.icon, i, 1, 4)
  end

  if not win_id or not vim.api.nvim_win_is_valid(win_id) then
    win_id = vim.api.nvim_open_win(buf_id, false, get_win_config(#lines))
    vim.wo[win_id].winblend = 0
    vim.wo[win_id].winhl = 'Normal:NONE'
  else
    vim.api.nvim_win_set_config(win_id, get_win_config(#lines))
  end
end

local function start_animation()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(0, 80, vim.schedule_wrap(function()
    frame = (frame % #config.spinner) + 1
    update_window()
  end))
end

-- ====================================================================
-- 🚀 核心架构优化：将自动命令封装进 setup 函数中
-- ====================================================================
function M.setup()
  local group = vim.api.nvim_create_augroup('diy_fidget_lsp', { clear = true })

  -- 监听进度
  vim.api.nvim_create_autocmd('LspProgress', {
    group = group,
    callback = function(args)
      local client_id = args.data.client_id
      local value = args.data.params.value
      local client = vim.lsp.get_client_by_id(client_id)
      if not client then return end

      if value.kind == 'begin' or value.kind == 'report' then
        active_tasks[client_id] = {
          title = client.name,
          message = value.message or value.title,
          percentage = value.percentage,
        }
        start_animation()
      elseif value.kind == 'end' then
        active_tasks[client_id] = nil
        vim.schedule(update_window)
      end
    end,
  })

  -- 监听 LSP 断开
  vim.api.nvim_create_autocmd('LspDetach', {
    group = group,
    callback = function(args)
      active_tasks[args.data.client_id] = nil
      vim.schedule(update_window)
    end
  })

  -- 💡 合理的优化建议：窗口大小改变时（比如终端最大化），重新计算位置
  vim.api.nvim_create_autocmd('VimResized', {
    group = group,
    callback = function()
      if win_id and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_set_config(win_id, get_win_config(vim.api.nvim_buf_line_count(buf_id)))
      end
    end
  })
end

return M
