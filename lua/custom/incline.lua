--NOTE: 可选 'none', 'rounded', 'single'
local M = {}
local win_cache = {}
local ns = vim.api.nvim_create_namespace('HandcraftedIncline')

M.config = {
  border = 'none',
  panel_bg = '#44406e',
}

local function get_hl_hex(name, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok and hl[attr] then return string.format('#%06x', hl[attr]) end
  return nil
end

local function get_contrast_color(hex_str)
  if not hex_str or #hex_str ~= 7 then return '#1e1e2e' end
  local r, g, b = tonumber(hex_str:sub(2, 3), 16), tonumber(hex_str:sub(4, 5), 16),
    tonumber(hex_str:sub(6, 7), 16)
  return (0.299 * r + 0.587 * g + 0.114 * b) > 128 and '#1e1e2e' or '#cdd6f4'
end

local function update_incline()
  local ok_wins, visible_wins = pcall(vim.api.nvim_tabpage_list_wins, 0)
  if not ok_wins then return end

  for _, win_id in ipairs(visible_wins) do
    if not vim.api.nvim_win_is_valid(win_id) then
      M.close(win_id)
      goto continue
    end

    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local ok_conf, config = pcall(vim.api.nvim_win_get_config, win_id)

    -- === 1. 甄别是否需要彻底销毁 ===
    -- 排除浮动窗口、无效 Buffer、终端/特殊页
    if not ok_conf or config.zindex or config.relative ~= '' or not vim.api.nvim_buf_is_valid(buf_id) or vim.bo[buf_id].buftype ~= '' then
      M.close(win_id)
      goto continue
    end

    -- === 2. 甄别是否需要暂时“隐身”防遮挡 ===
    local should_hide = false
    local cursor = vim.api.nvim_win_get_cursor(win_id)
    local win_info = vim.fn.getwininfo(win_id)[1]
    -- 当光标到达当前视口第一行时触发隐身
    if win_info and cursor[1] == win_info.topline then
      should_hide = true
    end

    -- === 3. 核心科技：状态 Hash 缓存器 ===
    local buf_path = vim.api.nvim_buf_get_name(buf_id)
    local filename = buf_path ~= '' and vim.fn.fnamemodify(buf_path, ':t') or '[No Name]'
    local modified = vim.bo[buf_id].modified
    local win_width = vim.api.nvim_win_get_width(win_id)

    -- 🌟 修复：将 should_hide 状态加入指纹 Hash，确保能触发状态翻转
    local state_hash = string.format('%d_%s_%s_%d_%s', buf_id, tostring(modified), filename,
      win_width, tostring(should_hide))
    local state = win_cache[win_id] or {}

    -- 如果一切没变（或者窗口没变且 Buffer 没丢），直接跳过（极致省 CPU 核心逻辑）
    if state.hash == state_hash and state.win and vim.api.nvim_win_is_valid(state.win) and state.buf and vim.api.nvim_buf_is_valid(state.buf) then
      goto continue
    end

    -- === 4. 处理隐身动作（不摧毁 Buffer）===
    if should_hide then
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        -- 🌟 性能大杀器：使用 hide = true 仅仅让其隐身，阻止垃圾回收器的剧烈抖动
        pcall(vim.api.nvim_win_set_config, state.win, { hide = true })
      end
      state.hash = state_hash
      win_cache[win_id] = state
      goto continue
    end

    -- === 5. 渲染新内容并显示 ===
    local icon, hl = '', 'Normal'
    local ok_icons, mini_icons = pcall(require, 'mini.icons')
    if ok_icons then icon, hl = mini_icons.get('file', filename) end

    local ft_color = get_hl_hex(hl, 'fg') or '#ABB2BF'
    local contrast_fg = get_contrast_color(ft_color)

    local safe_hl = hl:gsub('[^%w_]', '_')
    vim.api.nvim_set_hl(0, 'CIncIcon_' .. safe_hl, { fg = contrast_fg, bg = ft_color })
    vim.api.nvim_set_hl(0, 'CIncArrow_' .. safe_hl, { fg = ft_color, bg = M.config.panel_bg })
    vim.api.nvim_set_hl(0, 'CIncText', { fg = '#cdd6f4', bg = M.config.panel_bg, bold = modified })
    vim.api.nvim_set_hl(0, 'CIncMod', { fg = '#ff9e64', bg = M.config.panel_bg, bold = true })

    local chunks = {
      { ' ' .. icon .. ' ', 'CIncIcon_' .. safe_hl },
      { ' ', 'CIncArrow_' .. safe_hl },
      { filename, 'CIncText' }
    }
    if modified then table.insert(chunks, { ' [+]', 'CIncMod' }) end
    table.insert(chunks, { ' ', 'CIncText' })

    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
      state.buf = vim.api.nvim_create_buf(false, true)
    end

    local line_text = ''
    for _, chunk in ipairs(chunks) do line_text = line_text .. chunk[1] end
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, { line_text })
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)

    local byte_col = 0
    for _, chunk in ipairs(chunks) do
      vim.api.nvim_buf_add_highlight(state.buf, ns, chunk[2], 0, byte_col, byte_col + #chunk[1])
      byte_col = byte_col + #chunk[1]
    end

    local text_width = vim.fn.strdisplaywidth(line_text)
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
      zindex = 50,
      border = M.config.border,
      hide = false, -- 🌟 确保从顶端离开时，解除隐身重新显示！
    }

    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
      state.win = vim.api.nvim_open_win(state.buf, false, win_opts)
      local winhl = M.config.border == 'none' and 'NormalFloat:Normal,FloatBorder:Normal' or
        'NormalFloat:Normal'
      vim.wo[state.win].winhighlight = winhl
    else
      pcall(vim.api.nvim_win_set_config, state.win, win_opts)
    end

    -- 记录新状态
    state.hash = state_hash
    win_cache[win_id] = state
    ::continue::
  end
end

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

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  local group = vim.api.nvim_create_augroup('HandcraftedIncline', { clear = true })

  vim.api.nvim_create_autocmd(
    { 'WinScrolled', 'BufEnter', 'WinEnter', 'BufModifiedSet', 'VimResized', 'CursorMoved' }, {
      group = group,
      callback = function()
        vim.schedule(update_incline)
      end
    })

  vim.api.nvim_create_autocmd('WinClosed', {
    group = group, callback = function(args) M.close(tonumber(args.match)) end
  })
end

return M
