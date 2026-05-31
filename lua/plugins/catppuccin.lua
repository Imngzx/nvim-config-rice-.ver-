local resonance = require('resonance')
local utils = require('libs.utils')

local path_sep = utils.is_windows() and '\\' or '/'

resonance.load({
  plugin = {
    {
      src = 'https://github.com/catppuccin/nvim',
      version = 'main',
      build = function()
        vim.schedule(function()
          local ok, catppuccin = require('catppuccin')
          if ok and catppuccin then
            pcall(function()
              vim.cmd('CatppuccinCompile')
            end)
          end
        end)
      end
    }
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
        }
      end
    })
    vim.cmd.colorscheme('catppuccin')
  end
})

vim.api.nvim_exec_autocmds('User', { pattern = 'ForceLoadCatppuccin' })
