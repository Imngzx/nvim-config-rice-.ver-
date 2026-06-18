local resonance = require('resonance')
local utils = require('libs.utils')

local path_sep = utils.is_windows() and '\\' or '/'

resonance.load({
  plugin = {
    src = 'https://github.com/catppuccin/nvim',
    name = 'catppuccin',
    version = 'main',
  },

  event = { 'User', pattern = 'ForceLoadCatppuccin' },

  setup = function()
    require('catppuccin').setup({
      compile_path = vim.fn.stdpath('cache') .. path_sep .. 'catppuccin',
      flavour = 'mocha',
      transparent_background = false,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      integrations = {
        blink_cmp = { enabled = true, style = 'bordered' },
        markdown = true,
        mason = true,
        render_markdown = true,
        ufo = true,
        snacks = true,
        which_key = true,
        mini = true,
        treesitter_context = true,
        dropbar = { enabled = true, color_mode = false },
        flash = true,
        dap = true,
      },
      custom_highlights = function(colors)
        return {
          CursorLineNr = { bold = true },
          LineNr = { fg = colors.surface1 },
          NormalFloat = { bg = 'NONE' },
          FloatBorder = { bg = 'NONE', fg = colors.pink },
          FloatTitle = { bg = 'NONE' },
          BlinkCmpMenuBorder = { bg = 'NONE', fg = colors.pink },
          BlinkCmpDocBorder = { bg = 'NONE', fg = colors.blue },
          BlinkCmpSignatureHelpBorder = { bg = 'NONE', fg = colors.blue },
          WinBar = { bg = 'NONE' },
          WinBarNC = { bg = 'NONE' },
          DropBarMenuNormalFloat = { bg = 'NONE' },
          DropBarMenuBorder = { bg = 'NONE', fg = colors.surface1 },
          WhichKeyFloat = { bg = 'NONE' },

          SnacksIndentInactive = { fg = colors.surface1 },
          SnacksIndent1 = { fg = colors.red },
          SnacksIndent2 = { fg = colors.peach },
          SnacksIndent3 = { fg = colors.yellow },
          SnacksIndent4 = { fg = colors.green },
          SnacksIndent5 = { fg = colors.sapphire },
          SnacksIndent6 = { fg = colors.blue },
          SnacksIndent7 = { fg = colors.mauve },
        }
      end
    })
    vim.cmd.colorscheme('catppuccin')
  end
})

vim.api.nvim_exec_autocmds('User', { pattern = 'ForceLoadCatppuccin' })
