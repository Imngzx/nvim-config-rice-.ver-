local plaintex_loaded = vim.b.plaintex_loaded
local vim_o_local = vim.opt_local

if plaintex_loaded then return end
plaintex_loaded = true

vim_o_local.spell = true
vim_o_local.spelllang = { 'en_us', 'ms', 'cjk' }
