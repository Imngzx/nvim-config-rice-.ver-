local utils = require('libs.utils')
require('custom.ui2').setup()

--[Startup Profiler]
if vim.env.PROF then
  vim.cmd('packadd snacks.nvim')
  require('snacks.profiler').startup({
    startup = {
      event = 'VimEnter',
    },
  })
end

if not utils.is_compatible_version('0.13') then
  vim.notify('Need Neovim 0.13!', vim.log.levels.ERROR)
  return
end
