local M = {}

M.setup = function()
  local colors = {
    -- Basic
    bg = '#1b1d1e',
    fg = '#ADBAC7',
    comment = '#768390',
    string = '#96D0FF',
    func = '#DCBDFB',
    keyword = '#569CD6',
    ident = '#F69D50',
    cursorline = '#343C42',
    linenr = '#778095',
    visual_bg = '#264F78',
    error = '#ff6b6b',
    constant = '#6CB6FF',
    propname = '#4EC9B0',
    bracket = '#6CB6FF',

    -- Statusline
    status_bg = '#37424B',
    -- Tabline
    tabline_sel_fg = '#E0E2EA',

    -- LSP
    lsp_warn_fg = '#FFB86B',
    lsp_warn_bg = 'NONE',
    lsp_warn_line = '#FFB86B',
  }

  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') == 1 then vim.cmd('syntax reset') end
  vim.o.background = 'dark'
  vim.g.colors_name = 'mytheme'

  vim.api.nvim_set_hl(0, 'Normal', { fg = colors.fg, bg = colors.bg })
  vim.api.nvim_set_hl(0, 'Comment', { fg = colors.comment, italic = true })
  vim.api.nvim_set_hl(0, 'String', { fg = colors.string })
  vim.api.nvim_set_hl(0, 'Number', { fg = colors.string })
  vim.api.nvim_set_hl(0, 'Function', { fg = colors.func, bold = true })
  vim.api.nvim_set_hl(0, 'Keyword', { fg = colors.keyword, bold = true })
  vim.api.nvim_set_hl(0, 'Identifier', { fg = colors.ident })
  vim.api.nvim_set_hl(0, 'CursorLine', { bg = colors.cursorline })
  vim.api.nvim_set_hl(0, 'LineNr', { fg = colors.linenr })
  vim.api.nvim_set_hl(0, 'Visual', { bg = colors.visual_bg })
  vim.api.nvim_set_hl(0, 'Error', { fg = colors.error, bold = true })
  -- Constants / constants numeric
  vim.api.nvim_set_hl(0, 'Constant', { fg = colors.constant })
  vim.api.nvim_set_hl(0, 'Define', { fg = colors.constant })
  vim.api.nvim_set_hl(0, 'Type', { fg = colors.propname })
  vim.api.nvim_set_hl(0, 'Property', { fg = colors.propname })
  vim.api.nvim_set_hl(0, 'Label', { fg = colors.constant })
  -- variable.other -> use ident/fallback
  vim.api.nvim_set_hl(0, 'Variable', { fg = colors.ident })
  -- Support.type.property-name
  vim.api.nvim_set_hl(0, 'Identifier', { fg = colors.propname })
  -- Matching pairs / brackets
  vim.api.nvim_set_hl(0, 'MatchParen', { bg = '#2b2b3b', bold = true })
  vim.api.nvim_set_hl(0, 'Delimiter', { fg = colors.bracket })
  vim.api.nvim_set_hl(0, 'Special', { fg = colors.fg })
  vim.api.nvim_set_hl(0, 'Operator', { fg = colors.error })
  -- Popup / menu
  vim.api.nvim_set_hl(0, 'Pmenu', { fg = colors.fg, bg = '#252533' })
  vim.api.nvim_set_hl(0, 'PmenuSel', { fg = colors.bg, bg = colors.func })
  vim.api.nvim_set_hl(0, 'Search', { fg = colors.bg, bg = colors.fg })
  vim.api.nvim_set_hl(0, 'IncSearch', { fg = colors.bg, bg = colors.ident })
  -- LSP
  vim.api.nvim_set_hl(0, 'DiagnosticWarn', { fg = colors.lsp_warn_fg, bg = colors.lsp_warn_bg })
  vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = colors.lsp_warn_fg, bg = colors.lsp_warn_bg })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = colors.lsp_warn_line })
  -- Compatibility
  vim.api.nvim_set_hl(0, 'WarningMsg', { fg = colors.lsp_warn_fg, bg = colors.lsp_warn_bg, bold = true })
  vim.api.nvim_set_hl(0, 'LspDiagnosticsDefaultWarning', { fg = colors.lsp_warn_fg })
  vim.api.nvim_set_hl(0, 'LspDiagnosticsDefaultWarningSign', { fg = colors.lsp_warn_fg })
  vim.api.nvim_set_hl(0, 'LspDiagnosticsDefaultWarningVirtualText', { fg = colors.lsp_warn_fg })

  -- StatusLine / StatusLineNC）
  vim.api.nvim_set_hl(0, 'StatusLine', { fg = colors.fg, bg = colors.status_bg, bold = false })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = colors.fg, bg = colors.status_bg })
  -- Tabline
  vim.api.nvim_set_hl(0, 'TabLineSel', { fg = colors.tabline_sel_fg, bold = true })
end

return M
