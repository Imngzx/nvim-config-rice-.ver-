-- [Theme & Bug Fix]
local utils = require('libs.utils')

local path_sep = utils.is_windows() and '\\' or '/'

-- nvim/lua/custom/catppuccin.lua
vim.pack.add({ 'https://github.com/catppuccin/nvim' })
require('catppuccin').setup({

  -- NOTE: remember to :CatppuccinCompile first before long term of usage
  -- Because it can reduce the coloring time
  compile_path = vim.fn.stdpath('cache') .. path_sep .. 'catppuccin',

  -- HACK: mocha, frappe, macchiato, latte
  flavour = 'mocha',
  transparent_background = false, -- 如果你想全局透明可以改成 true
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
  integrations = {
    blink_cmp = true,
    markdown = true,
    mason = true,
    render_markdown = true,
    snacks = true,
    which_key = true,
    mini = true,
    treesitter_context = true,
  },
  custom_highlights = function(colors)
    return {
      -- === 现有：清空 Markdown 语法的背景色 ===
      -- ['@markup.heading.1.markdown'] = { bg = 'NONE' },
      -- ['@markup.heading.2.markdown'] = { bg = 'NONE' },
      -- ['@markup.heading.3.markdown'] = { bg = 'NONE' },
      -- ['@markup.heading.4.markdown'] = { bg = 'NONE' },
      -- ['@markup.heading.5.markdown'] = { bg = 'NONE' },
      -- ['@markup.heading.6.markdown'] = { bg = 'NONE' },
      -- ['@markup.heading.markdown'] = { bg = 'NONE' },
      -- ['markdownH1'] = { bg = 'NONE' },
      -- ['markdownH2'] = { bg = 'NONE' },
      -- ['markdownH3'] = { bg = 'NONE' },
      -- ['markdownH4'] = { bg = 'NONE' },
      -- ['markdownH5'] = { bg = 'NONE' },
      -- ['markdownH6'] = { bg = 'NONE' },

      -- === 👇 新增：强制清空所有浮动窗口和边框的背景色 ===
      --line number config
      CursorLineNr = { bold = true },
      LineNr = { fg = colors.surface1 },

      -- 原生 LSP 和通用浮动窗口边框
      NormalFloat = { bg = 'NONE' },
      FloatBorder = { bg = 'NONE', fg = colors.pink }, -- fg可以换成你喜欢的边框颜色
      FloatTitle = { bg = 'NONE' },

      -- Blink.cmp 菜单边框 (图1的问题所在)
      BlinkCmpMenuBorder = { bg = 'NONE', fg = colors.pink },
      BlinkCmpDocBorder = { bg = 'NONE', fg = colors.blue },
      BlinkCmpSignatureHelpBorder = { bg = 'NONE', fg = colors.blue },

      WinBar = { bg = 'NONE' },
      WinBarNC = { bg = 'NONE' },
      DropBarMenuNormalFloat = { bg = 'NONE' },
      DropBarMenuBorder = { bg = 'NONE', fg = colors.surface1 },


      WhichKeyFloat = { bg = 'NONE' },
    }
  end
})
vim.cmd.colorscheme('catppuccin')
