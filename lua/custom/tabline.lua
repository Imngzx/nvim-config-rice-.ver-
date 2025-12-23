-- Simple Tabline with icons, LSP diagnostics, and close button
-- https://github.com/akinsho/bufferline.nvim/blob/main/doc/bufferline.txt
local icons = require('libs.icons')
local M = {}

-- Default config
M.config = {
  -- Hide tabline when only one buffer is open
  hide_single_tab = false,
}

-- Setup function
M.setup = function(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Set initial showtabline value
  _G.SimpleTabline = M
  if M.config.hide_single_tab then
    M.update_showtabline()
  else
    vim.o.showtabline = 2
  end
  vim.o.tabline = '%! v:lua.SimpleTabline.render()'
  -- Create highlight groups
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

  -- Make tabline clickable
  vim.api.nvim_exec([[
    function! SimpleTablineSwitch(buf_id, clicks, button, mod)
      if a:button ==# 'l'
        execute 'buffer' a:buf_id
      elseif a:button ==# 'r'
        execute 'bdelete' a:buf_id
      endif
    endfunction

    function! SimpleTablineClose(buf_id, clicks, button, mod)
      execute 'bdelete' a:buf_id
    endfunction
  ]], false)
end

-- Update showtabline option based on buffer count
M.update_showtabline = function()
  local count = 0
  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      count = count + 1
      if count > 1 then break end -- Early exit optimization
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

  for name, opts in pairs(highlights) do
    opts.default = true
    vim.api.nvim_set_hl(0, name, opts)
  end
end

-- Get LSP diagnostics for buffer
M.get_diagnostics = function(buf_id)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }

  for _, diagnostic in ipairs(vim.diagnostic.get(buf_id)) do
    local severity = diagnostic.severity
    if severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif severity == vim.diagnostic.severity.WARN then
      counts.warn = counts.warn + 1
    elseif severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end

  return counts
end

-- Get highlight group based on buffer state and diagnostics
M.get_highlight = function(buf_id, is_current)
  if not is_current then return 'TablineHidden' end

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
  local icon = icons.get_icon_by_name(filename) or icons.basic.file

  -- Get diagnostics
  local diag_str = ''
  local diag = M.get_diagnostics(buf_id)
  if diag.error > 0 then diag_str = diag_str .. icons.lsp.error .. diag.error end
  if diag.warn > 0 then diag_str = diag_str .. icons.lsp.warn .. diag.warn end
  if diag_str ~= '' then diag_str = ' ' .. diag_str end

  -- Make tab clickable
  local switch_func = '%' .. buf_id .. '@SimpleTablineSwitch@'
  local close_func = '%' .. buf_id .. '@SimpleTablineClose@'

  -- Close button
  local close_icon = vim.bo[buf_id].modified and icons.basic.modify or icons.basic.close
  local close_btn = '%#TablineClose#' .. ' ' .. close_func .. close_icon .. '%X'

  -- Assemble tab
  local hl = '%#' .. M.get_highlight(buf_id, is_current) .. '#'
  return hl .. switch_func .. ' ' .. icon .. ' ' .. filename .. diag_str .. close_btn .. ' '
end

-- Render tabline
M.render = function()
  local tabs = {}
  local current_buf = vim.api.nvim_get_current_buf()

  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then table.insert(tabs, M.format_tab(buf_id, buf_id == current_buf)) end
  end

  return table.concat(tabs, '|') .. '%#TablineFill#'
end

return M
