local text_loaded = vim.b.text_loaded
local vim_o_local = vim.opt_local

if text_loaded then return end
text_loaded = true

vim_o_local.spell = true
vim_o_local.spelllang = { 'en_us', 'ms', 'cjk' }
