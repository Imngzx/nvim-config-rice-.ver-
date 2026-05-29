-- Bytecode cache
if vim.loader then
  vim.loader.enable()
end

-- disable fzf.vim from arch systems
local disabled_built_ins = {
  'fzf',
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

if not require('libs.utils').is_compatible_version('0.13') then
  vim.notify('Need Neovim 0.13!', vim.log.levels.ERROR)
  return
end
