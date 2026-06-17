local typst_loaded = vim.b.typst_loaded
local vim_o_local = vim.opt_local

if typst_loaded then return end
typst_loaded = true

vim_o_local.spell = true
vim_o_local.spelllang = { 'en_us', 'ms', 'cjk' }
