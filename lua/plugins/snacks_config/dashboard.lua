return {
  enabled = true,
  preset = {
    keys = {
      { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
      { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
      { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
      { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      -- { icon = ' ', key = 's', desc = 'Restore Session', action = ':RestoreSession' },
      { icon = ' ', key = 's', desc = 'Restore Session', action = ":lua require('custom.session').load(false)" },
      { icon = '󱑽 ', key = 'l', desc = 'Resonance', action = ":lua require('resonance').open_ui()" },
      { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
    },
  },
  sections = {
    { section = 'header' },
    { section = 'keys', gap = 1, padding = 1 },
    (function()
      local cached_result = nil

      return function()
        if cached_result and _G.end_time then
          return cached_result
        end

        local info = require('resonance.scanner').get_info()

        local ms = 0
        if _G.start_time then
          local calc_end = _G.end_time or vim.uv.hrtime()
          ms = (calc_end - _G.start_time) / 1e6
        end

        cached_result = {
          align = 'center',
          text = {
            { '󱐋 ', hl = 'Special' },
            { string.format('%d / %d', info.loaded, info.total), hl = 'Special' },
            { ' plugins loaded in ', hl = 'Comment' },
            { string.format('%.2f ms', ms), hl = 'Special' },
          },
          padding = 1,
        }

        return cached_result
      end
    end)(),
  },
}
