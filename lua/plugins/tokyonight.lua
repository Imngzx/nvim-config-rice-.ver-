vim.pack.add({ 'https://github.com/folke/tokyonight.nvim' })

---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup({
  -- 可选: storm, moon, night, day (moon 质感介于柔和与深邃之间，非常适合替换 mocha)
  style = 'storm',
  transparent = false, -- 全局透明开关，保持和你原本一样
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = 'dark',
    floats = 'transparent', -- 开启原生的浮窗透明支持
  },
  on_highlights = function(hl, c)
    hl.CursorLineNr = { bold = true }
    hl.LineNr = { fg = c.dark5 } -- 对应 catppuccin 的 surface1

    hl.NormalFloat = { bg = 'NONE' }
    hl.FloatBorder = { bg = 'NONE', fg = c.magenta } -- 对应原本的 pink 边框
    hl.FloatTitle = { bg = 'NONE' }

    hl.BlinkCmpMenuBorder = { bg = 'NONE', fg = c.magenta }
    hl.BlinkCmpDocBorder = { bg = 'NONE', fg = c.blue }
    hl.BlinkCmpSignatureHelpBorder = { bg = 'NONE', fg = c.blue }

    hl.WinBar = { bg = 'NONE' }
    hl.WinBarNC = { bg = 'NONE' }
    hl.DropBarMenuNormalFloat = { bg = 'NONE' }
    hl.DropBarMenuBorder = { bg = 'NONE', fg = c.dark5 }

    hl.WhichKeyFloat = { bg = 'NONE' }
  end,
})
vim.cmd.colorscheme('tokyonight')
