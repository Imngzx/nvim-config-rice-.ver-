-- Bytecode cache
if vim.loader then
  vim.loader.enable()
end

local disabled_built_ins = {
  'fzf',
  'gzip',
  'matchit',
  'netrwPlugin',
  'matchparen',
  'tarPlugin',
  'tutor',
  'zipPlugin',
  'tohtml'
}
for _, plugin in pairs(disabled_built_ins) do
  vim.g['loaded_' .. plugin] = 1
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
