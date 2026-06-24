-- Bytecode cache
if vim.loader then
  vim.loader.enable()
end

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
