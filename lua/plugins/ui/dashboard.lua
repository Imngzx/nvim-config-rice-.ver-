-- 主页仪表盘 Dashboard
-- https://github.com/nvimdev/dashboard-nvim
local M = {
  'glepnir/dashboard-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' }
}

function M.opts()
  -- 从另一个文件里获取
  local header = require("icons.char-pic")
  table.insert(header, 1, '') -- 开头空行
  table.insert(header, '')    -- 结尾空行
  local icons = require("icons")

  return {
    theme = 'hyper',
    -- shortcut_type = 'number',
    config = {
      header = header,
      -- packages = { enable = false }, -- show how many plugins neovim loaded
      shortcut = {
        {
          icon = icons.home.Package,
          desc = ' Update',
          group = '@property',
          action = 'Lazy update',
          key = 'u'
        },
        {
          icon = icons.home.File,
          desc = ' Files',
          group = 'Label',
          action = 'Telescope find_files',
          key = 'f',
        },
        {
          icon = icons.home.Home,
          desc = ' Sidebar',
          group = 'DiagnosticWarn',
          action = 'Neotree toggle',
          key = 't',
        },
        {
          icon = icons.home.Command,
          desc = ' Command',
          group = 'Directory',
          action = 'Telescope commands',
          key = 'c',
        },
      },
      project = {
        enable = true,
        limit = 6,
        icon = icons.home.Dashboard,
        label = '  Recent Projects:',
        action = 'Telescope find_files cwd='
      },
      mru = {
        limit = 6,
        icon = icons.home.History,
        label = '  Most Recent Files:',
      },
      footer = { '', icons.basic.Vim .. ' Powered by Neovim' },
    },
  }
end

return M
