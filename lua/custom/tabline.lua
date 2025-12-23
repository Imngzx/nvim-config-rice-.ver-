-- Simple Tabline with icons, LSP diagnostics, and close button
-- https://github.com/akinsho/bufferline.nvim/blob/main/doc/bufferline.txt
local icons = require('libs.icons')
local M = {}

-- Default config
M.config = {
  -- Hide tabline when only one buffer is open
  hide_single_tab = false,
  -- on_close: optional function(buf_id) -> boolean
  -- If provided, it's called when a close is requested. If it returns true,
  -- the module will NOT perform the default `bdelete`. If it returns false/nil,
  -- the module will run the default `bdelete <buf_id>`.
  on_close = nil,
  -- icons: function(filename) -> string, string
  ---@diagnostic disable-next-line: unused-local
  file_icons = function(filename) return '', 'Normal' end,
  icons = { close = '󰅖', modify = '●' },
  -- optional name for close highlight group
  close_hl = 'TablineClose',
}

-- Public: programmatic close helper (respects on_close)
M.close_buffer = function(buf_id)
  if type(M.config.on_close) == 'function' then
    local handled = M.config.on_close(buf_id)
    if handled then return end
  end
  -- default behavior
  pcall(vim.api.nvim_buf_delete, buf_id, { force = false })
end

-- Setup function
M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Set initial show tabline value
  _G.SimpleTabline = M
  -- v:lua click handlers
  ---@diagnostic disable-next-line: unused-local
  _G.SimpleTablineSwitch = function(buf_id, clicks, button, mods)
    if button == 'l' then
      vim.api.nvim_set_current_buf(buf_id)
    elseif button == 'r' then
      _G.SimpleTabline.close_buffer(buf_id)
    end
  end
  ---@diagnostic disable-next-line: unused-local
  _G.SimpleTablineClose = function(buf_id, clicks, button, mods)
    _G.SimpleTabline.close_buffer(buf_id)
  end

  if M.config.hide_single_tab then
    M.update_showtabline()
  else
    vim.o.showtabline = 2
  end
  vim.o.tabline = '%! v:lua.SimpleTabline.render()'
  M.create_highlights()

  local group = vim.api.nvim_create_augroup('SimpleTabline', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = M.create_highlights,
  })
  -- Update showtabline when buffers change
  if M.config.hide_single_tab then
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete', 'BufWipeout' }, {
      group = group,
      callback = function() M.update_showtabline() end,
    })
  end
end

-- Update showtabline option based on buffer count
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

-- Create highlight groups
M.create_highlights = function()
  local highlights = {
    TablineCurrent = { link = 'TabLineSel', bold = true },
    TablineHidden = { link = 'TabLine' },
    TablineFill = { link = 'TabLineFill' },
    TablineError = { fg = '#f38ba8', bold = true },
    TablineWarn = { fg = '#f9e2af', bold = true },
    TablineInfo = { fg = '#89b4fa', bold = true },
    TablineHint = { fg = '#94e2d5', bold = true },
  }

  highlights[M.config.close_hl] = { link = 'TabLine' }

  for name, opts in pairs(highlights) do
    opts.default = true
    vim.api.nvim_set_hl(0, name, opts)
  end
end

-- Get LSP diagnostics for buffer
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

-- Get highlight group based on buffer state and diagnostics
M.get_highlight = function(buf_id, is_current)
  if not is_current then
    return 'TablineHidden'
  end

  local diag = M.get_diagnostics(buf_id)
  if diag.error > 0 then return 'TablineError' end
  if diag.warn > 0 then return 'TablineWarn' end
  if diag.info > 0 then return 'TablineInfo' end
  if diag.hint > 0 then return 'TablineHint' end

  return 'TablineCurrent'
end

-- Format single tab
M.format_tab = function(buf_id, is_current)
  -- Get buffer name
  local bufname = vim.api.nvim_buf_get_name(buf_id)
  local filename = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'

  local icon, icon_hl = M.config.file_icons(filename)
  icon_hl = icon_hl or 'Normal'

  local diag = M.get_diagnostics(buf_id)
  local diag_str = ''
  if diag.error > 0 then diag_str = diag_str .. icons.lsp.error .. diag.error end
  if diag.warn > 0 then diag_str = diag_str .. icons.lsp.warn .. diag.warn end
  if diag_str ~= '' then diag_str = ' ' .. diag_str end

  -- v:lua click handlers
  local switch = '%' .. buf_id .. '@v:lua.SimpleTablineSwitch@'
  local close = '%' .. buf_id .. '@v:lua.SimpleTablineClose@'

  local close_icon = vim.bo[buf_id].modified and M.config.icons.modify or M.config.icons.close
  local close_btn = '%#' .. M.config.close_hl .. '# ' ..
    close .. close_icon .. '%X'

  local tab_hl = '%#' .. M.get_highlight(buf_id, is_current) .. '#'
  local icon_hl_str = '%#' .. icon_hl .. '#'
  return tab_hl .. switch
    .. ' ' .. icon_hl_str .. icon .. tab_hl
    .. ' ' .. filename .. diag_str .. close_btn
    .. ' '
end

-- Render tabline
M.render = function()
  local tabs = {}
  local current = vim.api.nvim_get_current_buf()

  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      table.insert(tabs, M.format_tab(buf_id, buf_id == current))
    end
  end

  return table.concat(tabs, '|') .. '%#TablineFill#'
end

return M
