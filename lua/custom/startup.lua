-- Bytecode cache
if vim.loader then
  vim.loader.enable()
end

_G.I = require('libs.icons')

local disabled_built_ins = {
  'fzf',
  'gzip',
  'matchit',
  'netrwPlugin',
  'netrwSettings',
  'netrwFileHandlers',
  'matchparen',
  'tarPlugin',
  'tutor',
  'zipPlugin',
  'tohtml',
}
for i = 1, #disabled_built_ins do
  vim.g['loaded_' .. disabled_built_ins[i]] = 1
end

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

-- PERF: changing picker due to powermode
-- fzf during battery mode
-- snacks during wall power mode
require('libs.power').setup({ enable_auto_switch = true })

-- NOTE: list of disabled plugin during battery mode
-- Snacks.animate, partial Snacks.picker
-- render-markdown.nvim
