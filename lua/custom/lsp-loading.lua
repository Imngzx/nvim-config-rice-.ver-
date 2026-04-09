local M = {}

-- [config area]
local config = {
  spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  icons = { check = '✓', error = '✗' },
  highlights = {
    spinner = 'DiagnosticWarn',
    check = 'DiagnosticOk',
    text = 'Comment',
    client = 'String',
    title = 'Normal',
  },
  border = 'none', -- none, single or rounded
  keep_done_ms = 1000,
}

local active_tasks = {}
local frame = 1
local timer = nil
local win_id = nil
local buf_id = nil
local ns = vim.api.nvim_create_namespace('diy_lsp_loading')

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
  if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
    vim.api.nvim_buf_delete(buf_id, { force = true })
    buf_id = nil
  end
end

local function truncate(str, max_len)
  if not str then return '' end
  if vim.fn.strchars(str) > max_len then
    return vim.fn.strcharpart(str, 0, max_len - 3) .. '...'
  end
  return str
end

local function get_win_config(width, height)
  return {
    relative = 'editor',
    anchor = 'SE',
    row = vim.o.lines - (vim.o.laststatus > 0 and 2 or 1),
    col = vim.o.columns,
    width = width,
    height = height,
    style = 'minimal',
    border = config.border,
    focusable = false,
    noautocmd = true,
    zindex = 50,
  }
end

local function update_window()
  if vim.tbl_isempty(active_tasks) then
    cleanup()
    return
  end

  local lines_data = {}
  local max_line_width = 1

  local sorted_tokens = vim.tbl_keys(active_tasks)
  table.sort(sorted_tokens,
    function(a, b) return active_tasks[a].created_at < active_tasks[b].created_at end)

  for _, token in ipairs(sorted_tokens) do
    local task = active_tasks[token]

    local icon = task.done and config.icons.check or config.spinner[frame]
    local icon_hl = task.done and config.highlights.check or config.highlights.spinner

    local title = task.title and task.title ~= '' and (task.title .. ' ') or ''
    local msg = truncate(task.message, 40)
    local perc = task.percentage and string.format('%3d%%', task.percentage) or ''

    local left_part = string.format('%s %s', msg, perc)
    left_part = left_part:gsub('^%s+', ''):gsub('%s+$', '')
    if left_part ~= '' then left_part = ' ' .. left_part end

    local client_name = '[' .. task.client_name .. '] '

    local chunks = {
      { icon .. ' ', icon_hl },
      { client_name, config.highlights.client },
      { title, config.highlights.title },
      { left_part, config.highlights.text },
    }

    local line_width = 0
    for _, chunk in ipairs(chunks) do
      line_width = line_width + vim.fn.strdisplaywidth(chunk[1])
    end
    max_line_width = math.max(max_line_width, line_width)

    table.insert(lines_data, { chunks = chunks, width = line_width })
  end

  local lines = {}
  local extmarks = {}

  for line_idx, data in ipairs(lines_data) do
    local padding_len = max_line_width - data.width
    local padding = string.rep(' ', padding_len)

    local line_text = padding
    local current_byte = #padding

    for _, chunk in ipairs(data.chunks) do
      local text, hl = chunk[1], chunk[2]
      if text and text ~= '' then
        line_text = line_text .. text
        table.insert(extmarks, {
          line = line_idx - 1,
          start_col = current_byte,
          end_col = current_byte + #text,
          hl_group = hl,
        })
        current_byte = current_byte + #text
      end
    end

    table.insert(lines, line_text)
  end

  if #lines == 0 then
    cleanup()
    return
  end

  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    buf_id = vim.api.nvim_create_buf(false, true)
    vim.bo[buf_id].bufhidden = 'wipe'
  end
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

  vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
  for _, em in ipairs(extmarks) do
    pcall(vim.api.nvim_buf_set_extmark, buf_id, ns, em.line, em.start_col, {
      end_row = em.line,
      end_col = em.end_col,
      hl_group = em.hl_group,
      priority = 20,
    })
  end

  if not win_id or not vim.api.nvim_win_is_valid(win_id) then
    win_id = vim.api.nvim_open_win(buf_id, false, get_win_config(max_line_width, #lines))
    vim.wo[win_id].winblend = 0
    vim.wo[win_id].winhl = 'Normal:NONE'
  else
    vim.api.nvim_win_set_config(win_id, get_win_config(max_line_width, #lines))
  end
end

local function start_animation()
  if timer and not timer:is_closing() then return end
  if timer and timer:is_closing() then timer = nil end

  timer = vim.uv.new_timer()
  if timer then
    timer:start(0, 80, vim.schedule_wrap(function()
      frame = (frame % #config.spinner) + 1
      update_window()
    end))
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('diy_lsp_loading', { clear = true })

  vim.api.nvim_create_autocmd('LspProgress', {
    group = group,
    callback = function(args)
      local client_id = args.data.client_id
      local token = args.data.params.token
      local value = args.data.params.value
      local client = vim.lsp.get_client_by_id(client_id)

      if not client or not token then return end

      if value.kind == 'begin' then
        active_tasks[token] = {
          client_name = client.name,
          title = value.title or '',
          message = value.message or '',
          percentage = value.percentage,
          done = false,
          created_at = vim.uv.hrtime(),
        }
        start_animation()
      elseif value.kind == 'report' then
        if active_tasks[token] and not active_tasks[token].done then
          active_tasks[token].message = value.message or active_tasks[token].message
          active_tasks[token].percentage = value.percentage or active_tasks[token].percentage
        end
      elseif value.kind == 'end' then
        if active_tasks[token] then
          active_tasks[token].done = true
          active_tasks[token].percentage = nil
          active_tasks[token].message = value.message or 'Done'

          vim.schedule(update_window)

          vim.defer_fn(function()
            active_tasks[token] = nil
            update_window()
          end, config.keep_done_ms)
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd('LspDetach', {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end
      for token, task in pairs(active_tasks) do
        if task.client_name == client.name then
          active_tasks[token] = nil
        end
      end
      vim.schedule(update_window)
    end
  })

  vim.api.nvim_create_autocmd('VimResized', {
    group = group,
    callback = function()
      if win_id and buf_id and vim.api.nvim_win_is_valid(win_id) and vim.api.nvim_buf_is_valid(buf_id) then
        local max_width = 10
        for _, line in ipairs(vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)) do
          max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
        end
        vim.api.nvim_win_set_config(win_id,
          get_win_config(max_width, vim.api.nvim_buf_line_count(buf_id)))
      end
    end
  })
end

return M
