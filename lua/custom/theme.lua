-- A Neovim theme inspired by GitHub Dark with custom colors

local M = {}

-- Color palette
local colors = {
  -- Base colors
  bg = '#1b1d1e',
  bg_tab = '#23272a',
  fg = '#ADBAC7',

  -- Syntax colors
  red = '#F47067',
  orange = '#F69D50',
  yellow = '#DAAA3F',
  green = '#4EC9B0',
  cyan = '#96D0FF',
  blue = '#6CB6FF',
  purple = '#DCBDFB',
  pink = '#FC8DC7',

  -- Additional colors
  comment = '#768390',
  ruler = '#404040',
  error = '#f74e54',
  salmon = '#FF938A',

  -- UI colors
  selection = '#3d424a',
  line_number = '#636e7b',
  cursor_line = '#22272e',
  visual = '#2d4f67',
  search = '#744C27',
  match_paren = '#3d424a',
}

-- Set highlight groups
function M.setup()
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  vim.o.background = 'dark'
  vim.g.colors_name = 'github-dark-custom'

  local hi = function(group, opts)
    local cmd = 'highlight ' .. group
    if opts.fg then cmd = cmd .. ' guifg=' .. opts.fg end
    if opts.bg then cmd = cmd .. ' guibg=' .. opts.bg end
    if opts.style then cmd = cmd .. ' gui=' .. opts.style end
    if opts.sp then cmd = cmd .. ' guisp=' .. opts.sp end
    vim.cmd(cmd)
  end

  -- Editor UI
  hi('Normal', { fg = colors.fg, bg = colors.bg })
  hi('NormalFloat', { fg = colors.fg, bg = colors.bg })
  hi('ColorColumn', { bg = colors.cursor_line })
  hi('Cursor', { fg = colors.bg, bg = colors.fg })
  hi('CursorLine', { bg = colors.cursor_line })
  hi('CursorLineNr', { fg = colors.fg })
  hi('LineNr', { fg = colors.line_number })
  hi('SignColumn', { bg = colors.bg })
  hi('Visual', { bg = colors.visual })
  hi('VisualNOS', { bg = colors.visual })
  hi('Search', { bg = colors.search })
  hi('IncSearch', { bg = colors.search, style = 'bold' })
  hi('MatchParen', { bg = colors.match_paren, style = 'bold' })

  -- Editor chrome
  hi('Pmenu', { fg = colors.fg, bg = colors.cursor_line })
  hi('PmenuSel', { bg = colors.selection })
  hi('PmenuSbar', { bg = colors.cursor_line })
  hi('PmenuThumb', { bg = colors.ruler })
  hi('StatusLine', { fg = colors.fg, bg = colors.bg_tab })
  hi('StatusLineNC', { fg = colors.comment, bg = colors.bg_tab })
  -- hi('TabLine', { fg = colors.comment, bg = colors.bg })
  -- hi('TabLineFill', { bg = colors.bg })
  -- hi('TabLineSel', { fg = colors.fg, bg = colors.bg_tab })
  hi('TabLine', { fg = colors.comment })
  hi('TabLineSel', { fg = colors.fg })
  hi('VertSplit', { fg = colors.ruler })
  hi('Folded', { fg = colors.comment, bg = colors.cursor_line })
  hi('FoldColumn', { fg = colors.comment, bg = colors.bg })

  -- Syntax highlighting
  hi('Comment', { fg = colors.comment, style = 'italic' })
  hi('Constant', { fg = colors.blue })
  hi('String', { fg = colors.cyan })
  hi('Character', { fg = colors.cyan })
  hi('Number', { fg = colors.cyan })
  hi('Boolean', { fg = colors.blue })
  hi('Float', { fg = colors.cyan })

  hi('Identifier', { fg = colors.fg })
  hi('Function', { fg = colors.purple })

  hi('Statement', { fg = colors.red })
  hi('Conditional', { fg = colors.red })
  hi('Repeat', { fg = colors.red })
  hi('Label', { fg = colors.red })
  hi('Operator', { fg = colors.red })
  hi('Keyword', { fg = colors.red })
  hi('Exception', { fg = colors.red })

  hi('PreProc', { fg = colors.red })
  hi('Include', { fg = colors.red })
  hi('Define', { fg = colors.red })
  hi('Macro', { fg = colors.red })
  hi('PreCondit', { fg = colors.red })

  hi('Type', { fg = colors.red })
  hi('StorageClass', { fg = colors.red })
  hi('Structure', { fg = colors.red })
  hi('Typedef', { fg = colors.red })

  hi('Special', { fg = colors.orange })
  hi('SpecialChar', { fg = colors.cyan })
  hi('Tag', { fg = colors.green })
  hi('Delimiter', { fg = colors.fg })
  hi('SpecialComment', { fg = colors.comment })
  hi('Debug', { fg = colors.red })

  hi('Underlined', { style = 'underline' })
  hi('Error', { fg = colors.error })
  hi('Todo', { fg = colors.purple, style = 'bold' })

  -- Treesitter
  hi('@variable', { fg = colors.fg })
  hi('@variable.builtin', { fg = colors.blue })
  hi('@variable.parameter', { fg = colors.orange })
  hi('@variable.member', { fg = colors.fg })

  hi('@constant', { fg = colors.blue })
  hi('@constant.builtin', { fg = colors.blue })
  hi('@constant.macro', { fg = colors.blue })

  hi('@module', { fg = colors.fg })
  hi('@label', { fg = colors.blue })

  hi('@string', { fg = colors.cyan })
  hi('@string.escape', { fg = colors.cyan })
  hi('@string.special', { fg = colors.cyan })
  hi('@character', { fg = colors.cyan })
  hi('@number', { fg = colors.cyan })
  hi('@boolean', { fg = colors.blue })
  hi('@float', { fg = colors.cyan })

  hi('@function', { fg = colors.purple })
  hi('@function.builtin', { fg = colors.purple })
  hi('@function.macro', { fg = colors.purple })
  hi('@function.method', { fg = colors.purple })

  hi('@constructor', { fg = colors.red })
  hi('@operator', { fg = colors.red })
  hi('@keyword', { fg = colors.red })
  hi('@keyword.function', { fg = colors.red })
  hi('@keyword.operator', { fg = colors.red })
  hi('@keyword.return', { fg = colors.red })
  hi('@keyword.control', { fg = colors.red })

  hi('@type', { fg = colors.red })
  hi('@type.builtin', { fg = colors.red })
  hi('@type.qualifier', { fg = colors.red })

  hi('@property', { fg = colors.green })
  hi('@attribute', { fg = colors.orange })
  hi('@field', { fg = colors.fg })

  hi('@punctuation.delimiter', { fg = colors.fg })
  hi('@punctuation.bracket', { fg = colors.fg })
  hi('@punctuation.special', { fg = colors.fg })

  hi('@comment', { fg = colors.comment, style = 'italic' })

  hi('@tag', { fg = colors.green })
  hi('@tag.attribute', { fg = colors.orange })
  hi('@tag.delimiter', { fg = colors.fg })

  -- LSP
  hi('DiagnosticError', { fg = colors.error })
  hi('DiagnosticWarn', { fg = colors.yellow })
  hi('DiagnosticInfo', { fg = colors.blue })
  hi('DiagnosticHint', { fg = colors.green })

  hi('LspReferenceText', { bg = colors.selection })
  hi('LspReferenceRead', { bg = colors.selection })
  hi('LspReferenceWrite', { bg = colors.selection })

  -- Diff
  hi('DiffAdd', { fg = colors.green, bg = '#1d3128' })
  hi('DiffChange', { fg = colors.yellow, bg = '#2e2811' })
  hi('DiffDelete', { fg = colors.red, bg = '#3b1719' })
  hi('DiffText', { fg = colors.yellow, bg = '#3d3014' })

  -- MiniDiff
  hi('MiniDiffSignAdd', { fg = colors.green })
  hi('MiniDiffSignChange', { fg = colors.yellow })
  hi('MiniDiffSignDelete', { fg = colors.red })

  -- Snacks
  hi('SnacksIndentScope', { fg = '#7C7C7C' })
  hi('SnacksPickerGitStatusAdded', { fg = '#81B88B' })
  hi('SnacksPickerGitStatusModified', { fg = '#E2C08D' })
  hi('SnacksPickerGitStatusDeleted', { fg = '#D27A6B' })
  hi('SnacksPickerGitStatusUntracked', { fg = colors.comment })
  hi('SnacksPickerDirectory', { fg = colors.fg }) -- Dir icon
  hi('SnacksPickerDir', { fg = colors.comment })  -- Dir path name

  -- MiniIcon
  hi('MiniIconsAzure', { fg = '#D2DADE' })
  hi('MiniIconsBlue', { fg = '#99CCF6' })
  hi('MiniIconsCyan', { fg = '#85D7DA' })
  hi('MiniIconsGreen', { fg = '#9ED6AF' })
  hi('MiniIconsGrey', { fg = '#D2DADE' })
  hi('MiniIconsOrange', { fg = '#ECBC90' })
  hi('MiniIconsPurple', { fg = '#C5BEF8' })
  hi('MiniIconsRed', { fg = '#F6B2B2' })
  hi('MiniIconsYellow', { fg = '#CACB8F' })

  hi('VirtColumn', { fg = '#3c3836' })
end

return M
