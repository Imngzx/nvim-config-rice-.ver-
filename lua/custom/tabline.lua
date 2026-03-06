-- Simple Tabline with icons, LSP diagnostics, and close button
local icons = require('libs.icons')
local M = {}

-- Default config
M.config = {
  hide_single_tab = false,
  on_close = nil,
  file_icons = function(filename)
    -- 兼容 mini.icons
    local ok, mini_icons = pcall(require, 'mini.icons')
    if ok then
      local icon, hl, _ = mini_icons.get('file', filename)
      return icon or '', hl or 'Normal'
    end
    return '', 'Normal'
  end,
  icons = { close = '󰅖', modify = '●' },
}

M.close_buffer = function(buf_id)
  if type(M.config.on_close) == 'function' then
    if M.config.on_close(buf_id) then return end
  end
  pcall(vim.api.nvim_buf_delete, buf_id, { force = false })
end

-- [核心美化逻辑] 动态高亮生成器，完美融合图标前景色与 Tab 背景色
M.hl_cache = {}
local function get_dynamic_hl(fg_color, bg_hl, bold)
  local cache_key = (fg_color or 'none') .. '_' .. bg_hl .. '_' .. tostring(bold)
  if M.hl_cache[cache_key] then return M.hl_cache[cache_key] end

  -- 提取前景色
  local fg_val
  if fg_color and fg_color:sub(1, 1) == '#' then
    fg_val = fg_color
  elseif fg_color then
    local ok, hl_def = pcall(vim.api.nvim_get_hl, 0, { name = fg_color, link = false })
    if ok and hl_def.fg then fg_val = string.format('#%06x', hl_def.fg) end
  end

  -- 提取背景色 (Tab 的背景)
  local bg_val
  local ok, bg_def = pcall(vim.api.nvim_get_hl, 0, { name = bg_hl, link = false })
  if ok and bg_def.bg then bg_val = string.format('#%06x', bg_def.bg) end

  -- 生成新的混合高亮组
  local new_hl_name = 'TablineDyn_' .. cache_key:gsub('#', ''):gsub(' ', '')
  vim.api.nvim_set_hl(0, new_hl_name, { fg = fg_val, bg = bg_val, bold = bold })

  M.hl_cache[cache_key] = new_hl_name
  return new_hl_name
end

M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  _G.SimpleTabline = M

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
  M.hl_cache = {} -- 切换主题时清理缓存
  vim.api.nvim_set_hl(0, 'TablineCurrent', { link = 'TabLineSel', bold = true, default = true })
  vim.api.nvim_set_hl(0, 'TablineHidden', { link = 'TabLine', default = true })
  vim.api.nvim_set_hl(0, 'TablineFill', { link = 'TabLineFill', default = true })
end

M.get_diagnostics = function(buf_id)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }
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
  return counts
end

M.format_tab = function(buf_id, is_current)
  local bufname = vim.api.nvim_buf_get_name(buf_id)
  local filename = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'

  -- 获取当前 Tab 的基准背景
  local bg_hl = is_current and 'TablineCurrent' or 'TablineHidden'
  local tab_hl = '%#' .. bg_hl .. '#'

  -- 图标 (动态融合背景色)
  local icon, icon_group = M.config.file_icons(filename)
  local icon_hl = get_dynamic_hl(icon_group or 'Normal', bg_hl, false)
  local icon_str = '%#' .. icon_hl .. '# ' .. icon .. ' '

  -- 诊断信息 (带有柔和颜色并融入背景)
  local diag = M.get_diagnostics(buf_id)
  local diag_str = ''
  if diag.error > 0 then
    local err_hl = get_dynamic_hl('#ED8796', bg_hl, true) -- 红色
    diag_str = diag_str .. '%#' .. err_hl .. '#' .. icons.lsp.error .. diag.error .. ' '
  end
  if diag.warn > 0 then
    local warn_hl = get_dynamic_hl('#EED49F', bg_hl, true) -- 黄色
    diag_str = diag_str .. '%#' .. warn_hl .. '#' .. icons.lsp.warn .. diag.warn .. ' '
  end

  -- 未保存/关闭按钮 (解决割裂感)
  local is_modified = vim.bo[buf_id].modified
  local close_icon = is_modified and M.config.icons.modify or M.config.icons.close
  -- 如果未保存，给圆点上 Catppuccin 橙色，否则使用默认背景色
  local btn_hl = is_modified and get_dynamic_hl('#F5A97F', bg_hl, true) or bg_hl

  local switch = '%' .. buf_id .. '@v:lua.SimpleTablineSwitch@'
  local close = '%' .. buf_id .. '@v:lua.SimpleTablineClose@'

  local close_btn = '%#' .. btn_hl .. '#' .. close .. close_icon .. '%X '

  -- 组装字符串，加入前后舒适的空格间距
  return tab_hl .. switch .. icon_str .. tab_hl .. filename .. ' ' .. diag_str .. close_btn
end

M.render = function()
  local tabs = {}
  local current = vim.api.nvim_get_current_buf()

  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      table.insert(tabs, M.format_tab(buf_id, buf_id == current))
    end
  end

  -- 使用更有质感的细线作为分隔符，配合左右空隙
  local separator = '%#TablineFill# | '
  return table.concat(tabs, separator) .. '%#TablineFill#'
end

return M
