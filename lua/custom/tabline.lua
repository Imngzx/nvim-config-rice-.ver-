-- Simple Tabline with icons, LSP diagnostics, and close button (Viewport Scroll Enabled)
local icons = require('libs.icons')
local M = {}
local mini_icons_cache = nil

local fn_fnamemodify = vim.fn.fnamemodify
local fn_strchars = vim.fn.strchars
local fn_strcharpart = vim.fn.strcharpart

M._name_cache = {}

M.config = {
  max_name_length = 20,
  hide_single_tab = false,
  on_close = nil,
  file_icons = function(filename)
    if mini_icons_cache == nil then
      local ok, mini_icons = pcall(require, 'mini.icons')
      mini_icons_cache = ok and mini_icons or false
    end

    if mini_icons_cache then
      local icon, hl, _ = mini_icons_cache.get('file', filename)
      return icon or '', hl or 'Normal'
    end
    return '', 'Normal'
  end,
  icons = { close = '󰅖', modify = '●' },
}

M.viewport_start = 1

M.close_buffer = function(buf_id)
  if type(M.config.on_close) == 'function' then
    if M.config.on_close(buf_id) then return end
  end
  pcall(vim.api.nvim_buf_delete, buf_id, { force = false })
end

M.hl_cache = {}
local function get_dynamic_hl(fg_color, bg_hl, bold)
  local cache_key = (fg_color or 'none') .. '_' .. bg_hl .. '_' .. tostring(bold)
  if M.hl_cache[cache_key] then return M.hl_cache[cache_key] end

  local fg_val
  if fg_color and fg_color:sub(1, 1) == '#' then
    fg_val = fg_color
  elseif fg_color then
    local ok, hl_def = pcall(vim.api.nvim_get_hl, 0, { name = fg_color, link = false })
    if ok and hl_def.fg then fg_val = string.format('#%06x', hl_def.fg) end
  end

  local bg_val
  local ok, bg_def = pcall(vim.api.nvim_get_hl, 0, { name = bg_hl, link = false })
  if ok and bg_def.bg then bg_val = string.format('#%06x', bg_def.bg) end

  local new_hl_name = 'TablineDyn_' .. cache_key:gsub('#', ''):gsub(' ', '')
  vim.api.nvim_set_hl(0, new_hl_name, { fg = fg_val, bg = bg_val, bold = bold })

  M.hl_cache[cache_key] = new_hl_name
  return new_hl_name
end

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  _G.SimpleTabline = M

  -- 点击 Tab 切换/关闭的回调
  _G.SimpleTablineSwitch = function(buf_id, clicks, button, mods)
    if button == 'l' then
      vim.api.nvim_set_current_buf(buf_id)
    elseif button == 'r' then
      _G.SimpleTabline.close_buffer(buf_id)
    end
  end

  _G.SimpleTablineClose = function(buf_id, clicks, button, mods)
    _G.SimpleTabline.close_buffer(buf_id)
  end

  _G.SimpleTablineScrollLeft = function()
    M.viewport_start = math.max(1, M.viewport_start - 1)
    vim.cmd.redrawtabline()
  end

  _G.SimpleTablineScrollRight = function()
    M.viewport_start = M.viewport_start + 1
    vim.cmd.redrawtabline()
  end

  if M.config.hide_single_tab then M.update_showtabline() else vim.o.showtabline = 2 end
  vim.o.tabline = '%! v:lua.SimpleTabline.render()'

  M.create_highlights()
  local group = vim.api.nvim_create_augroup('SimpleTabline', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = M.create_highlights })
  if M.config.hide_single_tab then
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete', 'BufWipeout' }, {
      group = group, callback = function() M.update_showtabline() end,
    })
  end

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(args)
      M._name_cache[args.buf] = nil
    end,
  })
end

M.update_showtabline = function()
  local count = 0
  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      count = count + 1
      if count > 1 then break end
    end
  end
  vim.o.showtabline = count > 1 and 2 or 0
end

M.create_highlights = function()
  M.hl_cache = {}
  vim.api.nvim_set_hl(0, 'TablineCurrent', { link = 'TabLineSel', bold = true, default = true })
  vim.api.nvim_set_hl(0, 'TablineHidden', { link = 'TabLine', default = true })
  vim.api.nvim_set_hl(0, 'TablineFill', { link = 'TabLineFill', default = true })
end

M.get_diagnostics = function(buf_id)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }
  if vim.diagnostic.count then
    local d = vim.diagnostic.count(buf_id)
    counts.error = d[vim.diagnostic.severity.ERROR] or 0
    counts.warn = d[vim.diagnostic.severity.WARN] or 0
    counts.info = d[vim.diagnostic.severity.INFO] or 0
    counts.hint = d[vim.diagnostic.severity.HINT] or 0
  else
    for _, diagnostic in ipairs(vim.diagnostic.get(buf_id)) do
      local s = diagnostic.severity
      if s == vim.diagnostic.severity.ERROR then
        counts.error = counts.error + 1
      elseif s == vim.diagnostic.severity.WARN then
        counts.warn = counts.warn + 1
      elseif s == vim.diagnostic.severity.INFO then
        counts.info = counts.info + 1
      elseif s == vim.diagnostic.severity.HINT then
        counts.hint = counts.hint + 1
      end
    end
  end
  return counts
end

M.format_tab = function(buf_id, is_current)
  local bufname = vim.api.nvim_buf_get_name(buf_id)

  local cached = M._name_cache[buf_id]
  local filename
  local icon_filename

  if cached and cached.raw_path == bufname then
    filename = cached.display_name
    icon_filename = cached.icon_filename
  else
    icon_filename = bufname ~= '' and fn_fnamemodify(bufname, ':t') or '[No Name]'
    local bpm_ok, bpm = pcall(require, 'bpm')
    if bpm_ok then
      filename = bpm.resolve_bufname(buf_id)
    else
      filename = icon_filename
      local max_len = M.config.max_name_length
      if max_len and max_len > 0 and #filename > max_len then
        if fn_strchars(filename) > max_len then
          filename = fn_strcharpart(filename, 0, max_len - 1) .. '…'
        end
      end
    end

    M._name_cache[buf_id] = {
      raw_path = bufname,
      display_name = filename,
      icon_filename =
        icon_filename
    }
  end

  local bg_hl = is_current and 'TablineCurrent' or 'TablineHidden'
  local tab_hl = '%#' .. bg_hl .. '#'

  local icon, icon_group = M.config.file_icons(icon_filename)
  local icon_hl = get_dynamic_hl(icon_group or 'Normal', bg_hl, false)
  local icon_str = '%#' .. icon_hl .. '# ' .. icon .. ' '

  local diag = M.get_diagnostics(buf_id)
  local diag_str = ''
  if diag.error > 0 then
    local err_hl = get_dynamic_hl('#ED8796', bg_hl, true)
    diag_str = diag_str .. '%#' .. err_hl .. '#' .. icons.lsp.error .. diag.error .. ' '
  end
  if diag.warn > 0 then
    local warn_hl = get_dynamic_hl('#EED49F', bg_hl, true)
    diag_str = diag_str .. '%#' .. warn_hl .. '#' .. icons.lsp.warn .. diag.warn .. ' '
  end

  local is_modified = vim.bo[buf_id].modified
  local close_icon = is_modified and M.config.icons.modify or M.config.icons.close
  local btn_hl = is_modified and get_dynamic_hl('#F5A97F', bg_hl, true) or bg_hl

  local switch = '%' .. buf_id .. '@v:lua.SimpleTablineSwitch@'
  local close = '%' .. buf_id .. '@v:lua.SimpleTablineClose@'

  local close_btn = '%#' .. btn_hl .. '#' .. close .. close_icon .. '%X '

  return tab_hl .. switch .. icon_str .. tab_hl .. filename .. ' ' .. diag_str .. close_btn
end

M.render = function()
  local tabs = {}
  local current = vim.api.nvim_get_current_buf()
  local current_idx = 0

  -- 尊重你的选择：保留原版竖线分隔符
  local sep_str = '%#TablineFill# | '
  local sep_width = 3

  -- 1. 收集所有 Tab，并预先计算它们的纯文本显示宽度
  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      local is_current = (buf_id == current)
      local str = M.format_tab(buf_id, is_current)

      -- 去除 Neovim 的 % 高亮和点击标识，用来计算真实的占据宽度
      local clean_str = str:gsub('%%#.-#', ''):gsub('%%%d+@.-@', ''):gsub('%%X', '')
      local width = vim.fn.strdisplaywidth(clean_str)

      table.insert(tabs, { str = str, width = width })
      if is_current then current_idx = #tabs end
    end
  end

  if #tabs == 0 then return '' end

  if M.viewport_start > #tabs then M.viewport_start = #tabs end
  if M.viewport_start < 1 then M.viewport_start = 1 end

  -- 避免光标不在 tab 里（如在文件树树里）时乱跳
  if current_idx == 0 then current_idx = M.viewport_start end

  -- 2. 验证滑动窗口位置
  if current_idx < M.viewport_start then
    M.viewport_start = current_idx
  end

  local max_width = vim.o.columns

  local left_ind = '%0@v:lua.SimpleTablineScrollLeft@%#TablineFill#  %X'
  local right_ind = '%0@v:lua.SimpleTablineScrollRight@%#TablineFill#  %X'
  local ind_width = 3

  -- 计算从 start_idx 开始，最多能显示到哪一个 tab
  local function get_visible_end(start_idx)
    local w = 0
    if start_idx > 1 then w = w + ind_width end
    local end_idx = start_idx

    for i = start_idx, #tabs do
      local next_w = w + tabs[i].width
      if i > start_idx then next_w = next_w + sep_width end
      if i < #tabs then next_w = next_w + ind_width end -- 预留右侧箭头的空间

      if next_w > max_width and i > start_idx then
        break
      end

      w = w + tabs[i].width
      if i > start_idx then w = w + sep_width end
      end_idx = i
    end
    return end_idx
  end

  local end_idx = get_visible_end(M.viewport_start)

  -- 如果当前标签超出了右侧边界，将窗口向右推
  while current_idx > end_idx do
    M.viewport_start = M.viewport_start + 1
    end_idx = get_visible_end(M.viewport_start)
  end

  -- 3. 渲染最终字符串
  local res = ''
  if M.viewport_start > 1 then
    res = res .. left_ind .. sep_str
  end

  for i = M.viewport_start, end_idx do
    res = res .. tabs[i].str
    if i < end_idx then
      res = res .. sep_str
    end
  end

  if end_idx < #tabs then
    res = res .. sep_str .. right_ind
  end

  return res .. '%#TablineFill#'
end

return M
