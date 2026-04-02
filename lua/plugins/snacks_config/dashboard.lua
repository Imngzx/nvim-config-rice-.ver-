return {
  enabled = true,
  preset = {
    keys = {
      { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
      { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
      { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
      { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      -- 👇 点击 s 键时，触发你上面定义的命令，瞬间唤醒手搓懒加载引擎！
      -- { icon = ' ', key = 's', desc = 'Restore Session', action = ':RestoreSession' },
      -- 把 action = ':RestoreSession' 替换为下面这行
      { icon = ' ', key = 's', desc = 'Restore Session', action = ":lua require('custom.session').load(false)" },
      { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
    },
  },
  sections = {
    { section = 'header' },
    { section = 'keys', gap = 1, padding = 1 },

    -- 使用「闭包缓存」：只在第一次见面时计算，之后彻底冻结结果
    (function()
      local cached_result = nil

      return function()
        if cached_result then return cached_result end

        local plugin_dir = vim.fn.stdpath('data') .. '/site/pack/core/opt'
        local total_count = 0
        local loaded_count = 0

        if vim.fn.isdirectory(plugin_dir) == 1 then
          local plugins = vim.fn.readdir(plugin_dir)
          total_count = #plugins

          local rtps = vim.api.nvim_list_runtime_paths()
          for _, p in ipairs(plugins) do
            local p_path = vim.fs.normalize(plugin_dir .. '/' .. p)
            for _, rtp in ipairs(rtps) do
              if vim.fs.normalize(rtp) == p_path then
                loaded_count = loaded_count + 1
                break
              end
            end
          end
        end

        local ms = 0
        if _G.start_time then
          ms = math.floor((vim.uv.hrtime() - _G.start_time) / 1e6 * 100 + 0.5) / 100
        end

        cached_result = {
          align = 'center',
          text = {
            { '󱐋 ', hl = 'Special' },
            { tostring(loaded_count) .. ' / ' .. tostring(total_count), hl = 'Special' },
            { ' plugins loaded in ', hl = 'Comment' },
            { tostring(ms) .. ' ms', hl = 'Special' },
          },
          padding = 1,
        }

        return cached_result
      end
    end)(),
  },
}
