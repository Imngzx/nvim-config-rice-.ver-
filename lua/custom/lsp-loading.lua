local M = {}

local config = {
  spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  icons = { lsp = '󰒋' },
  highlights = {
    icon = 'DiagnosticWarn',
    msg = 'Comment',
  }
}

local active_tasks = {} -- 存储 client_id -> { title, message, percentage }
local frame = 1
local timer = nil
local win_id = nil
local buf_id = nil

-- 清理函数：彻底关闭窗口和定时器
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

-- 获取窗口配置
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

-- 更新窗口 UI
local function update_window()
  -- 如果没有活跃任务，直接清理并退出
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

  -- 创建/维护 Buffer
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    buf_id = vim.api.nvim_create_buf(false, true)
  end
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

  -- 高亮处理
  local ns = vim.api.nvim_create_namespace('diy_fidget')
  vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
  for i = 0, #lines - 1 do
    vim.api.nvim_buf_add_highlight(buf_id, ns, config.highlights.icon, i, 1, 4)
  end

  -- 显示/移动窗口
  if not win_id or not vim.api.nvim_win_is_valid(win_id) then
    win_id = vim.api.nvim_open_win(buf_id, false, get_win_config(#lines))
    vim.wo[win_id].winblend = 15
    vim.wo[win_id].winhl = 'Normal:NormalFloat'
  else
    vim.api.nvim_win_set_config(win_id, get_win_config(#lines))
  end
end

-- 启动动画循环
local function start_animation()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(0, 80, vim.schedule_wrap(function()
    frame = (frame % #config.spinner) + 1
    update_window()
  end))
end

-- 监听进度
vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('diy_fidget_lsp', { clear = true }),
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
      -- 延迟一会给 update_window 机会清理
      vim.schedule(update_window)
    end
  end,
})

-- 监听 LSP 断开
vim.api.nvim_create_autocmd('LspDetach', {
  callback = function(args)
    active_tasks[args.data.client_id] = nil
    vim.schedule(update_window)
  end
})

return M
