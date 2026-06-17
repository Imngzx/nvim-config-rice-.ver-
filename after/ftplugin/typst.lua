if vim.b.typst_loaded then return end
vim.b.typst_loaded = true

vim.opt_local.spell = true
vim.opt_local.spelllang = { 'en_us', 'ms', 'cjk' }
