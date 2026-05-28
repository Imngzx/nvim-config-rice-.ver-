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
        -- 缓存命中直接返回
        if cached_result then
          return cached_result
        end

        local info = require('resonance.scanner').get_info()

        local ms = 0
        if _G.start_time then
          -- 💡 终极秘诀：Dashboard 画出来的这一瞬间，用户已经看到了界面。
          -- 所以我们在这里直接充当“裁判”按下秒表！
          -- 如果 _G.end_time 还没被设置，Dashboard 就在这毫秒把它永远锁死。
          _G.end_time = _G.end_time or vim.uv.hrtime()

          ms = (_G.end_time - _G.start_time) / 1e6
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
