if vim.b.plaintex_loaded then return end
vim.b.plaintex_loaded = true

vim.opt_local.spell = true
vim.opt_local.spelllang = { 'en_us', 'ms', 'cjk' }
