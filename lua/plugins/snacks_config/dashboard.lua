return {
  enabled = true,
  preset = {
    keys = {
      { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
      { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
      { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
      { icon = ' ', key = 'z', desc = 'Zoxide Dirs', action = ':lua Snacks.picker.zoxide()' },
      { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      { icon = ' ', key = 's', desc = 'Restore Session', action = ":lua require('custom.session').load(false)" },
      { icon = '󱑽 ', key = 'l', desc = 'Resonance', action = ":lua require('resonance').open_ui()" },
      { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
    },
  },
  sections = {
    { section = 'header' },
    { section = 'keys', gap = 1, padding = 1 },
    function()
      local stats = require('resonance').stats()
      local ms = string.format('%.2f ms', stats.startuptime)
      return {
        align = 'center',
        text = {
          { '󱐋 ', hl = 'Special' },
          { stats.loaded .. ' / ' .. stats.count, hl = 'Special' },
          { ' plugins loaded in ', hl = 'Comment' },
          { ms, hl = 'Special' },
        },
        padding = 1,
      }
    end,
  },
}
