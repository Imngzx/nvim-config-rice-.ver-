-- 底部状态栏
-- https://github.com/nvim-lualine/lualine.nvim
return {
  'nvim-lualine/lualine.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = "VeryLazy",
  opts = function()
    local custom_auto = require 'lualine.themes.auto'

    -- Change the background of lualine_c section
    local transparent = "NONE"
    custom_auto.normal.c.bg = transparent
    custom_auto.insert.c.bg = transparent
    custom_auto.visual.c.bg = transparent
    custom_auto.command.c.bg = transparent
    custom_auto.inactive.c.bg = transparent
    custom_auto.terminal.c.bg = transparent
    return {
      options = {
        icons_enabled = true,
        theme = custom_auto,
        section_separators = { left = '', right = '' },
        component_separators = { left = '|', right = '|' }
      }
    }
  end
}
