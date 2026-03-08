-- 手搓版 Incline (右上角浮动状态栏) - 稳定版
-- 修复了针对 Snacks.picker 的窗口无效 ID 报错

local M = {}
local win_cache = {}
local ns = vim.api.nvim_create_namespace('HandcraftedIncline')

-- 算法：计算对比色
local function get_contrast_color(hex_str)
  if not hex_str or #hex_str ~= 7 then return '#1e1e2e' end
  local r = tonumber(hex_str:sub(2, 3), 16) or 0
  local g = tonumber(hex_str:sub(4, 5), 16) or 0
  local b = tonumber(hex_str:sub(6, 7), 16) or 0
  local luminance = (0.299 * r + 0.587 * g + 0.114 * b)
  return luminance > 128 and '#1e1e2e' or '#cdd6f4'
end

-- 获取高亮组的 HEX 颜色
local function get_hl_hex(name, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok and hl[attr] then return string.format('#%06x', hl[attr]) end
  return nil
end

local function update_incline()
  -- 获取当前页所有窗口
  local ok_wins, visible_wins = pcall(vim.api.nvim_tabpage_list_wins, 0)
  if not ok_wins then return end

  -- 检查是否处于 Snacks Zen 模式
  local in_zen, zen_win = false, nil
  local ok_snacks, snacks = pcall(require, 'snacks')
  if ok_snacks and snacks.zen and snacks.zen.win and not snacks.zen.win.closed then
    in_zen = true
    zen_win = snacks.zen.win.win
  end

  for _, win_id in ipairs(visible_wins) do
    -- [核心修复]：每次操作前必须校验窗口是否仍然有效
    if not vim.api.nvim_win_is_valid(win_id) then
      M.close(win_id)
      goto continue
    end

    local is_valid = true

    -- 1. 过滤逻辑
    local ok_conf, config = pcall(vim.api.nvim_win_get_config, win_id)
    if not ok_conf or config.zindex or config.relative ~= '' then
      is_valid = false
    end

    -- Zen 模式过滤
    if in_zen and win_id ~= zen_win then is_valid = false end

    -- 缓冲区过滤
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    if not vim.api.nvim_buf_is_valid(buf_id) then is_valid = false end

    if is_valid then
      local buftype = vim.bo[buf_id].buftype
      if buftype == 'nofile' or buftype == 'prompt' or buftype == 'terminal' then
        is_valid = false
      end
    end

    -- 2. 防遮挡：光标在顶行时隐藏
    if is_valid then
      local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, win_id)
      local ok_info, info = pcall(vim.fn.getwininfo, win_id)
      if ok_cursor and ok_info and info[1] and cursor[1] == info[1].topline then
        is_valid = false
      end
    end

    -- 如果无效，清理该窗口的 Incline
    if not is_valid then
      M.close(win_id)
      goto continue
    end

    -- 3. 准备渲染数据
    local buf_path = vim.api.nvim_buf_get_name(buf_id)
    local filename = buf_path ~= '' and vim.fn.fnamemodify(buf_path, ':t') or '[No Name]'

    -- 获取图标
    local icon, hl = '', 'Normal'
    local ok_icons, mini_icons = pcall(require, 'mini.icons')
    if ok_icons then
      icon, hl = mini_icons.get('file', filename)
    end

    local ft_color = get_hl_hex(hl, 'fg') or '#ABB2BF'
    local contrast_fg = get_contrast_color(ft_color)
    local modified = vim.bo[buf_id].modified
    local panel_bg = '#44406e'

    -- 4. 动态生成高亮组 (使用带后缀的名称防止冲突)
    local safe_hl = hl:gsub('[^%w_]', '_')
    vim.api.nvim_set_hl(0, 'CIncIcon_' .. safe_hl, { fg = contrast_fg, bg = ft_color })
    vim.api.nvim_set_hl(0, 'CIncArrow_' .. safe_hl, { fg = ft_color, bg = panel_bg })
    vim.api.nvim_set_hl(0, 'CIncText', { fg = '#cdd6f4', bg = panel_bg, bold = modified })
    vim.api.nvim_set_hl(0, 'CIncMod', { fg = '#ff9e64', bg = panel_bg, bold = true })

    -- 5. 拼装文本
    local chunks = {
      { ' ' .. icon .. ' ', 'CIncIcon_' .. safe_hl },
      { ' ', 'CIncArrow_' .. safe_hl },
      { filename, 'CIncText' }
    }
    if modified then table.insert(chunks, { ' [+]', 'CIncMod' }) end
    table.insert(chunks, { ' ', 'CIncText' })

    -- 6. 更新缓冲区内容
    local state = win_cache[win_id] or {}
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
      state.buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(state.buf, 'buftype', 'nofile')
    end

    local text_width = 0
    local line_text = ''
    for _, chunk in ipairs(chunks) do
      text_width = text_width + vim.fn.strdisplaywidth(chunk[1])
      line_text = line_text .. chunk[1]
    end

    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, { line_text })
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)

    local byte_col = 0
    for _, chunk in ipairs(chunks) do
      local len = #chunk[1]
      vim.api.nvim_buf_add_highlight(state.buf, ns, chunk[2], 0, byte_col, byte_col + len)
      byte_col = byte_col + len
    end

    -- 7. 浮窗参数
    local win_width = vim.api.nvim_win_get_width(win_id)
    local win_opts = {
      relative = 'win',
      win = win_id,
      anchor = 'NE',
      row = 0,
      col = win_width - 1,
      width = text_width,
      height = 1,
      style = 'minimal',
      focusable = false,
      zindex = 50, -- 调高层级，确保在其他组件上方
      noautocmd = true,
    }

    -- 创建或移动浮窗
    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
      local ok_open, new_win = pcall(vim.api.nvim_open_win, state.buf, false, win_opts)
      if ok_open then
        state.win = new_win
        vim.wo[state.win].winhighlight = 'NormalFloat:Normal'
      end
    else
      pcall(vim.api.nvim_win_set_config, state.win, win_opts)
    end

    win_cache[win_id] = state

    ::continue::
  end
end

-- 关闭指定窗口关联的 Incline
function M.close(win_id)
  local state = win_cache[win_id]
  if state then
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      pcall(vim.api.nvim_win_close, state.win, true)
    end
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
      pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
    end
    win_cache[win_id] = nil
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('HandcraftedIncline', { clear = true })

  vim.api.nvim_create_autocmd(
  { 'WinScrolled', 'BufEnter', 'WinEnter', 'BufModifiedSet', 'CursorMoved', 'VimResized' }, {
    group = group,
    callback = function()
      -- 使用 schedule_wrap 更加稳健
      vim.schedule(function()
        update_incline()
      end)
    end
  })

  -- 显式处理窗口关闭，清理缓存防止内存泄漏和报错
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(args)
      local id = tonumber(args.match)
      if id then M.close(id) end
    end
  })
end

return M
