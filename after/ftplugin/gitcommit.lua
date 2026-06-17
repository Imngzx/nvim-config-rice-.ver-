local gitcommit_loaded = vim.b.gitcommit_loaded
local vim_o_local = vim.opt_local

if gitcommit_loaded then return end
gitcommit_loaded = true

vim_o_local.spell = true
vim_o_local.spelllang = { 'en_us', 'ms', 'cjk' }
