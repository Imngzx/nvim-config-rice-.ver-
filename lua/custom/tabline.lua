-- Simple Tabline with icons, LSP diagnostics, and close button
local icons = require('libs.icons')
local M = {}

M.config = {
  hide_single_tab = false,
  on_close = nil,
  file_icons = function(filename)
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
  M.hl_cache = {}
  vim.api.nvim_set_hl(0, 'TablineCurrent', { link = 'TabLineSel', bold = true, default = true })
  vim.api.nvim_set_hl(0, 'TablineHidden', { link = 'TabLine', default = true })
  vim.api.nvim_set_hl(0, 'TablineFill', { link = 'TabLineFill', default = true })
end

M.get_diagnostics = function(buf_id)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }
  -- 👇 性能修复：使用 O(1) 的 count 方法，拒绝在重绘时生成大字典
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
  local filename = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'

  local bg_hl = is_current and 'TablineCurrent' or 'TablineHidden'
  local tab_hl = '%#' .. bg_hl .. '#'

  local icon, icon_group = M.config.file_icons(filename)
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
  local pre_tabs = {}
  local post_tabs = {}
  local current_tab_str = ''

  local current = vim.api.nvim_get_current_buf()
  local found_current = false

  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      local is_current = (buf_id == current)
      local tab_str = M.format_tab(buf_id, is_current)

      -- 把标签拆分成：当前之前、当前、当前之后
      if is_current then
        current_tab_str = tab_str
        found_current = true
      elseif not found_current then
        table.insert(pre_tabs, tab_str)
      else
        table.insert(post_tabs, tab_str)
      end
    end
  end

  local separator = '%#TablineFill# | '
  local res = ''

  if #pre_tabs > 0 then
    res = res .. table.concat(pre_tabs, separator) .. separator
  end

  -- 👇 核心魔法：使用 `%<` 截断标记。
  -- 放在当前活动窗口的正前方，当长度超出屏幕时，Neovim 会自动吃掉左侧不可见的窗口，让当前窗口永远展示在屏幕上！
  res = res .. '%<' .. current_tab_str

  if #post_tabs > 0 then
    res = res .. separator .. table.concat(post_tabs, separator)
  end

  return res .. '%#TablineFill#'
end

return M
