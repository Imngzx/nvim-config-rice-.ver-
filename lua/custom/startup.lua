local utils = require('libs.utils')

_G.start_time = vim.uv.hrtime()
_G.end_time = nil

vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    _G.end_time = vim.uv.hrtime()
    vim.cmd('redrawstatus')
  end
})

--[Startup Profiler]
if vim.env.PROF then
  vim.cmd('packadd snacks.nvim')
  require('snacks.profiler').startup({
    startup = {
      event = 'VimEnter',
    },
  })
end

if not utils.is_compatible_version('0.12') then
  vim.notify('Need Neovim 0.12+', vim.log.levels.ERROR)
  return
end
