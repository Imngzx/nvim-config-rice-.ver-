local resonance = require('resonance')

resonance.load({
  {
    'https://github.com/rebelot/heirline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local heirline = require('heirline')
      local utils = require('heirline.utils')
      local colors = require('plugins.heirline_config.colors')
      local WinBar = require('plugins.heirline_config.winbar')

      heirline.load_colors(colors.setup_colors())

      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function() utils.on_colorscheme(colors.setup_colors) end,
      })

      require('libs.git').setup({
        get_git_root = function(filepath)
          local ok, snacks = pcall(require, 'snacks')
          return ok and snacks.git.get_root(filepath) or nil
        end
      })

      local StatusLine = require('plugins.heirline_config.statusline')
      local TabLine = require('plugins.heirline_config.tabline')

      heirline.setup({
        statusline = StatusLine,
        tabline = TabLine,
        winbar = WinBar,
        opts = {
          disable_winbar_cb = function(args)
            local bt = vim.api.nvim_get_option_value('buftype', { buf = args.buf })
            local ft = vim.api.nvim_get_option_value('filetype', { buf = args.buf })
            return bt == 'nofile' or bt == 'prompt' or bt == 'terminal' or bt == 'help' or
              ft == 'snacks_dashboard' or ft:match('^snacks_picker')
          end,
        }
      })
    end
  },

  {
    'https://github.com/aurora0x27/bpm.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('bpm').setup()
    end
  },
})
