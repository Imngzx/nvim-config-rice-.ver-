require('dashboard').setup {
  theme = 'hyper',
  -- shortcut_type = 'number',
  config = {
    header = {
      '',
      '╔═╗┌┬┐┌─┐┬ ┬  ╦ ╦┬ ┬┌┐┌┌─┐┬─┐┬ ┬ ',
      '╚═╗ │ ├─┤└┬┘  ╠═╣│ │││││ ┬├┬┘└┬┘ ',
      '╚═╝ ┴ ┴ ┴ ┴   ╩ ╩└─┘┘└┘└─┘┴└─ ┴┘\'',
      '╔═╗┌┬┐┌─┐┬ ┬  ╔═╗┌─┐┌─┐┬  ┬┌─┐┬ ┬',
      '╚═╗ │ ├─┤└┬┘  ╠╣ │ ││ ││  │└─┐├─┤',
      '╚═╝ ┴ ┴ ┴ ┴   ╚  └─┘└─┘┴─┘┴└─┘┴ ┴',
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
        action = 'Neotree toggle',
        key = 't',
      },
      {
        desc = ' Command',
        group = 'Number',
        action = 'Telescope commands',
        key = 'c',
      },
    },
    project = {
      enable = true,
      limit = 6,
      icon = '',
      label = '  Recent Projects:',
      action = 'Telescope find_files cwd='
    },
    mru = {
      limit = 6,
      icon = '',
      label = '  Most Recent Files:',
    },
    footer = { '', ' Powered by Neovim' },
  },
}
