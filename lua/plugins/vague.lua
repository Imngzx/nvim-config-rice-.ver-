vim.pack.add({ 'https://github.com/vague-theme/vague.nvim' })

require('vague').setup({
  transparent = false,

  style = {
    comments = 'italic',
    strings = 'none',
    keywords = 'none',
    functions = 'none',
    variables = 'none',
  },
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('VagueCustomHighlights', { clear = true }),
  callback = function()
    local set_hl = vim.api.nvim_set_hl

    local border_color = '#646477'

    set_hl(0, 'NormalFloat', { bg = 'NONE' })
    set_hl(0, 'FloatBorder', { bg = 'NONE', fg = border_color })
    set_hl(0, 'FloatTitle', { bg = 'NONE' })

    set_hl(0, 'BlinkCmpMenuBorder', { bg = 'NONE', fg = border_color })
    set_hl(0, 'BlinkCmpDocBorder', { bg = 'NONE', fg = border_color })
    set_hl(0, 'BlinkCmpSignatureHelpBorder', { bg = 'NONE', fg = border_color })

    set_hl(0, 'WinBar', { bg = 'NONE' })
    set_hl(0, 'WinBarNC', { bg = 'NONE' })
    set_hl(0, 'DropBarMenuNormalFloat', { bg = 'NONE' })
    set_hl(0, 'DropBarMenuBorder', { bg = 'NONE', fg = border_color })

    set_hl(0, 'WhichKeyFloat', { bg = 'NONE' })
  end
})

vim.cmd.colorscheme('vague')
