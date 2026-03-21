local utils = require('libs.utils')

_G.start_time = vim.uv.hrtime()

--[Startup Profiler]
-- 只有在终端输入 PROF=1 nvim 时才会触发，平时完全不占用性能！
if vim.env.PROF then
  -- 强行在第 1 毫秒提前唤醒 snacks.nvim
  vim.cmd('packadd snacks.nvim')
  require('snacks.profiler').startup({
    startup = {
      event = 'VimEnter', -- 当 Neovim 彻底启动完成时停止录制
    },
  })
end

if not utils.is_compatible_version('0.12') then
  vim.notify('Need Neovim 0.12+', vim.log.levels.ERROR)
  return
end
