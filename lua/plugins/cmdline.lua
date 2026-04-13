local lazy = require('libs.lazy')

local row = 0.25

-- check if it is launch under neovide
local check_neovide = not vim.g.neovide

lazy.load({
  plugin = 'https://github.com/aurora0x27/popup.nvim',

  event = { 'User', pattern = 'VeryLazy' },

  setup = function()
    require('popup').setup({
      enable_ui2 = check_neovide,
      views = {
        cmdline = {
          width = 0.45,
          col = 0.5,
          row = row,
          relative = 'editor',
        },
        input = {
          width = 0.55,
          col = 0.5,
          row = row,
          relative = 'editor',
        },
        lsp_rename = {
          width = 0.20,
          col = 1,
          row = 1,
          relative = 'cursor',
        },
      },

      routes = {
        {
          match = { firstc = '/' },
          prefix = ' ',
          title = 'Search',
          hl = 'CmdlineSearchDown',
          ft = 'regex',
          view = 'cmdline',
        },
        {
          match = { firstc = '?' },
          prefix = ' ',
          title = 'Search',
          hl = 'CmdlineSearchUp',
          ft = 'regex',
          view = 'cmdline',
        },
        {
          match = { firstc = ':', pattern = '%s*he?l?p?%s+' },
          prefix = '?',
          title = 'Help',
          hl = 'CmdlineHelp',
          view = 'cmdline',
        },
        {
          match = { firstc = ':', pattern = '%s*lua%s+' },
          prefix = ' ',
          title = 'Lua',
          hl = 'CmdlineLua',
          ft = 'lua',
          view = 'cmdline',
        },
        {
          match = { firstc = ':', pattern = '%s*%!' },
          prefix = '$',
          title = 'Filter',
          hl = 'CmdlineFilter',
          ft = 'bash',
          view = 'cmdline',
        },
        {
          match = { firstc = '', prompt = 'New Name' },
          prefix = '󰥻 ',
          hl = 'LspRenameInput',
          view = 'lsp_rename',
        },
        {
          match = { firstc = ':' },
          prefix = '',
          hl = 'CmdlineDefault',
          title = 'Cmdline',
          ft = 'vim',
          view = 'cmdline',
        },
        {
          match = { firstc = '' },
          prefix = '󰥻 ',
          hl = 'CmdlineInput',
          view = 'input',
        },
      },
    })
  end
})
