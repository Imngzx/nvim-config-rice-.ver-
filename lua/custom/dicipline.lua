-- from devaslife https://github.com/craftzdog/dotfiles-public/blob/master/.config/nvim/lua/craftzdog/discipline.lua
local M = {}

local config = {
  enabled = true
}

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})

  if not config.enabled then return end

  local now = vim.uv.now
  local get_count = function() return vim.v.count end

  local keys = { 'h', 'j', 'k', 'l', '+', '-' }
  local states = {}

  for _, key in ipairs(keys) do
    states[key] = { count = 0, last_time = 0 }

    vim.keymap.set('n', key, function()
      local exec_key = key
      if key == 'j' then exec_key = 'gj' end
      if key == 'k' then exec_key = 'gk' end

      if get_count() > 0 then
        states[key].count = 0
        return exec_key
      end

      if vim.bo.buftype ~= '' then
        return exec_key
      end

      local current_time = now()
      local state = states[key]

      if current_time - state.last_time > 2000 then
        state.count = 0
      end

      state.last_time = current_time
      state.count = state.count + 1

      if state.count >= 10 then
        pcall(vim.notify, 'Hold it! use Enter or F in normal mode', vim.log.levels.WARN, {
          title = 'NVIM',
          id = 'cowboy_spam_blocker',
        })
        return ''
      end

      return exec_key
    end, { expr = true, silent = true, desc = 'Cowboy motion ' .. key })
  end
end

return M
