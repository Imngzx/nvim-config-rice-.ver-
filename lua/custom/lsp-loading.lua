local M = {}

-- === 配置与样式 ===
local config = {
  spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  icons = {
    lsp = '󰒋',
    done = '󰄬',
    error = '󰅙',
  },
  highlights = {
    title = 'DiagnosticInfo',
    icon = 'DiagnosticWarn',
    msg = 'Comment',
    percentage = 'Number',
  }
}

-- 状态存储
local active_tasks = {} -- 存储 client_id -> { title, message, percentage, last_update }
local frame = 1
local timer = nil
local win_id = nil
local buf_id = nil

-- === 浮动窗口管理 ===
local function get_win_config(lines_count)
  return {
    relative = 'editor',
    anchor = 'SE',
    row = vim.o.lines - (vim.o.laststatus > 0 and 3 or 1), -- 放在 lualine 之上
    col = vim.o.columns - 1,
    width = 40,
    height = lines_count > 0 and lines_count or 1,
    style = 'minimal',
    focusable = false,
    noautocmd = true,
    zindex = 50, -- 确保在其他浮窗之下，但在文字之上
  }
end

local function update_window()
  local lines = {}
  local highlights = {}
  local sorted_clients = vim.tbl_keys(active_tasks)
  table.sort(sorted_clients)

  for i, client_id in ipairs(sorted_clients) do
    local task = active_tasks[client_id]
    local spinner_icon = config.spinner[frame]
    local percentage = task.percentage and string.format(' %d%%', task.percentage) or ''

    -- 构建行文本: 󰒋 [Spinner] LSPName: Message 80%
    local line = string.format(' %s %s %s: %s%s ',
      config.icons.lsp, spinner_icon, task.title or 'LSP', task.message or '', percentage)
    table.insert(lines, line)

    -- 记录高亮位置 (简化版：整行设色或局部设色)
    table.insert(highlights,
      { line_idx = i - 1, col_start = 1, col_end = 4, group = config.highlights.icon })
  end

  if #lines == 0 then
    if win_id and vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
      win_id = nil
    end
    return
  end

  -- 创建或更新 Buffer
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    buf_id = vim.api.nvim_create_buf(false, true)
  end
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

  -- 应用高亮 (使用 namespace)
  local ns = vim.api.nvim_create_namespace('diy_fidget')
  vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf_id, ns, hl.group, hl.line_idx, hl.col_start, hl.col_end)
  end

  -- 创建或更新 Window
  if not win_id or not vim.api.nvim_win_is_valid(win_id) then
    win_id = vim.api.nvim_open_win(buf_id, false, get_win_config(#lines))
    vim.wo[win_id].winblend = 15 -- 半透明美化
    vim.wo[win_id].winhl = 'Normal:NormalFloat'
  else
    vim.api.nvim_win_set_config(win_id, get_win_config(#lines))
  end
end

-- === 动画驱动 ===
local function start_animation()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(0, 80, vim.schedule_wrap(function()
    frame = (frame % #config.spinner) + 1
    update_window()
    if vim.tbl_isempty(active_tasks) then
      M.stop_animation()
    end
  end))
end

function M.stop_animation()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

-- === LSP 进度监听 ===
vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('diy_fidget_lsp', { clear = true }),
  callback = function(args)
    local client_id = args.data.client_id
    local value = args.data.params.value -- kind, title, message, percentage
    local client = vim.lsp.get_client_by_id(client_id)
    local client_name = client and client.name or 'Unknown'

    if value.kind == 'begin' or value.kind == 'report' then
      active_tasks[client_id] = {
        title = client_name,
        message = value.message or value.title,
        percentage = value.percentage,
      }
      start_animation()
    elseif value.kind == 'end' then
      active_tasks[client_id] = nil
    end
  end,
})

-- 窗口大小改变时自动调整位置
vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    if win_id and vim.api.nvim_win_is_valid(win_id) then
      update_window()
    end
  end,
})

return M
