local lazy = require('libs.lazy')

lazy.load({
  plugin = 'https://github.com/rebelot/heirline.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  setup = function()
    local heirline = require('heirline')
    local utils = require('heirline.utils')
    local colors = require('plugins.heirline_config.colors')

    heirline.load_colors(colors.setup_colors())

    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function() utils.on_colorscheme(colors.setup_colors) end,
    })

    -- require('libs.git').setup()
    require('libs.git').setup({
      get_git_root = function(filepath)
        local ok, snacks = pcall(require, 'snacks')
        return ok and snacks.git.get_root(filepath) or nil
      end
    })

    local StatusLine = require('plugins.heirline_config.components')
    heirline.setup({ statusline = StatusLine })
  end
})
