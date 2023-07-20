require('dashboard').setup {
  theme = 'hyper',
  -- shortcut_type = 'number',
  config = {
    header = {
      '',
      '   _______       __           __    __',
      '  / ____/ |     / /___  _____/ /___/ /',
      ' / /    | | /| / / __ \\/ ___/ / __  / ',
      '/ /___  | |/ |/ / /_/ / /  / / /_/ /  ',
      '\\____/  |__/|__/\\____/_/  /_/\\__,_/   ',
      ''
    },
    -- week_header = {
    --   enable = true,
    -- },
    -- packages = { enable = false }, -- show how many plugins neovim loaded
    shortcut = {
      {
        desc = ' Update',
        group = '@property',
        action = 'Lazy update',
        key = 'u'
      },
      {
        desc = ' Files',
        group = 'Label',
        action = 'Telescope find_files',
        key = 'f',
      },
      {
        desc = ' Sidebar',
        group = 'DiagnosticHint',
        action = 'NvimTreeToggle',
        key = 'b',
      },
      {
        desc = ' Command',
        group = 'Number',
        action = 'Telescope commands',
        key = 'c',
      },
    },
    footer = { '', ' Powered by Neovim' },
  },
}
